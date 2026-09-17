#!/usr/bin/env bash

IN=${1:?Usage: ./run_reco.sh SIM.edm4hep.root OUTPUT_BASENAME [N]}
BASE=${2:?Usage: ./run_reco.sh SIM.edm4hep.root OUTPUT_BASENAME [N]}
N=${3:-100}

[[ -f "$IN" ]] || { echo "ERROR: input file not found: $IN"; exit 1; }
[[ -n "${DETECTOR:-}" ]] || {
  echo "ERROR: DETECTOR is unset. Run: source setup.sh"
  exit 1
}
[[ -f CLDConfig/CLDConfig/CLDReconstruction.py ]] || {
  echo "ERROR: CLDReconstruction.py not found. Run: source setup.sh"
  exit 1
}

k4run CLDConfig/CLDConfig/CLDReconstruction.py \
  --inputFiles "$IN" \
  --outputBasename "$BASE" \
  --compactFile "$DETECTOR" \
  --trackingOnly \
  --conformalTracking \
  -n "$N"

OUT="${BASE}_REC.edm4hep.root"
[[ -s "$OUT" ]] || {
  echo "ERROR: expected reconstruction output not found: $OUT"
  exit 1
}
echo "Reconstruction complete: $OUT"
