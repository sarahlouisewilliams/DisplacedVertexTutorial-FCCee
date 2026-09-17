#!/bin/bash

# ============================================================
# CLD displaced-track radius scan
#
# For each DV radius:
#   1. Generate HepMC3 sample
#   2. Run DD4hep/Geant4 full simulation
#   3. Run CLD reconstruction with ConformalTracking
#
# Usage:
#   ./run_radius_scan.sh [number_of_events]
#
# Example:
#   ./run_radius_scan.sh 10
#   ./run_radius_scan.sh 100
# ============================================================

NEVENTS=${1:-10}
MOMENTUM=10

RADII=(
    0
    10
    20
    30
    40
    50
    60
    70
    80
    90
    100
    120
    150
    200
)

# ------------------------------------------------------------
# Basic checks
# ------------------------------------------------------------

if [[ ! -x ./generate_dv_sample ]]; then
    echo "ERROR: ./generate_dv_sample not found or not executable"
    exit 1
fi

if [[ ! -x ./run_fullsim.sh ]]; then
    echo "ERROR: ./run_fullsim.sh not found or not executable"
    exit 1
fi

if [[ ! -x ./run_reco.sh ]]; then
    echo "ERROR: ./run_reco.sh not found or not executable"
    exit 1
fi

if [[ -z "${DETECTOR:-}" ]]; then
    echo "ERROR: DETECTOR is not set."
    echo "Run:"
    echo "    source setup.sh"
    echo "first."
    exit 1
fi

echo
echo "============================================================"
echo " CLD displaced-track radius scan"
echo "============================================================"
echo "Events per point : ${NEVENTS}"
echo "Muon momentum    : ${MOMENTUM} GeV"
echo "Radii [mm]       : ${RADII[*]}"
echo "============================================================"
echo

# ------------------------------------------------------------
# Run scan
# ------------------------------------------------------------

for R in "${RADII[@]}"; do

    PREFIX="dv_r${R}"

    GEN="${PREFIX}.hepmc3"
    SIM="${PREFIX}_SIM.edm4hep.root"
    REC="${PREFIX}_REC.edm4hep.root"

    echo
    echo "============================================================"
    echo " DV radius = ${R} mm"
    echo "============================================================"

    # --------------------------------------------------------
    # 1. Generator
    # --------------------------------------------------------

    echo
    echo "[1/3] Generating events..."

    ./generate_dv_sample \
        --nev "${NEVENTS}" \
        --radius "${R}" \
        --momentum "${MOMENTUM}" \
        --output "${GEN}"

    if [[ ! -s "${GEN}" ]]; then
        echo "ERROR: generation failed at R=${R} mm"
        exit 1
    fi

    # --------------------------------------------------------
    # 2. Full simulation
    # --------------------------------------------------------

    echo
    echo "[2/3] Running full simulation..."

    ./run_fullsim.sh \
        "${GEN}" \
        "${SIM}" \
        "${NEVENTS}"

    if [[ ! -s "${SIM}" ]]; then
        echo "ERROR: simulation failed at R=${R} mm"
        exit 1
    fi

    # --------------------------------------------------------
    # 3. Reconstruction
    # --------------------------------------------------------

    echo
    echo "[3/3] Running reconstruction..."

    ./run_reco.sh \
        "${SIM}" \
        "${PREFIX}" \
        "${NEVENTS}"

    if [[ ! -s "${REC}" ]]; then
        echo "ERROR: reconstruction failed at R=${R} mm"
        exit 1
    fi

    echo
    echo "Completed R=${R} mm"
    echo "  GEN: ${GEN}"
    echo "  SIM: ${SIM}"
    echo "  REC: ${REC}"

done

echo
echo "============================================================"
echo " Radius scan complete"
echo "============================================================"
echo
echo "Now run:"
echo
echo "    root -l -b -q analyse_radius_scan.C"
echo
echo "followed by:"
echo
echo "    python plot_radius_scan.py"
echo