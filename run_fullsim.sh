#!/bin/bash

IN=${1:?Usage: ./run_fullsim.sh INPUT.hepmc3 OUTPUT.edm4hep.root [N]}
OUT=${2:?Usage: ./run_fullsim.sh INPUT.hepmc3 OUTPUT.edm4hep.root [N]}
N=${3:-100}
[[ -f "$IN" ]] || { echo "ERROR: input file not found: $IN"; exit 1; }
[[ -n "${DETECTOR:-}" ]] || { echo "ERROR: run: source setup.sh"; exit 1; }
rm -f "$OUT"
LOG="${OUT%.root}.ddsim.log"
set +e
ddsim --compactFile "$DETECTOR" --inputFiles "$IN" --outputFile "$OUT" \
      --numberOfEvents "$N" --crossingAngleBoost 0 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e
if [[ $rc -ne 0 ]] || grep -Eq "Run Must Be Aborted|event parsing failed|G4Exception.*Error" "$LOG"; then
  echo "ERROR: full simulation failed. See $LOG"
  exit 1
fi
[[ -s "$OUT" ]] || { echo "ERROR: no non-empty output file"; exit 1; }
echo "Full simulation complete: $OUT"
