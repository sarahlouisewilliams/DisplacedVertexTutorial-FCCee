#!/usr/bin/env bash
set -euo pipefail

R=${1:?Usage: ./run_point.sh RADIUS_MM [N] [MOMENTUM_GEV]}
N=${2:-100}
P=${3:-10}

# Safe filename representation for non-integer radii/momenta.
RTAG=${R//./p}
PTAG=${P//./p}
TAG="r${RTAG}_p${PTAG}"

mkdir -p samples sim reco logs

[[ -x ./generate_dv_sample ]] || ./build_generator.sh

# Derive a reproducible integer seed from the radius string.
SEED=$(python3 - "$R" <<'PY'
import sys
r=float(sys.argv[1])
print(12345 + int(round(1000*r)))
PY
)

./generate_dv_sample \
  --nev "$N" \
  --radius "$R" \
  --momentum "$P" \
  --seed "$SEED" \
  --output "samples/${TAG}.hepmc3"

./run_fullsim.sh \
  "samples/${TAG}.hepmc3" \
  "sim/${TAG}_SIM.edm4hep.root" \
  "$N" 2>&1 | tee "logs/${TAG}_sim.log"

./run_reco.sh \
  "sim/${TAG}_SIM.edm4hep.root" \
  "reco/${TAG}" \
  "$N" 2>&1 | tee "logs/${TAG}_reco.log"

echo "Output: reco/${TAG}_REC.edm4hep.root"
