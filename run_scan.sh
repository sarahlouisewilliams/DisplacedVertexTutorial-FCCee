#!/usr/bin/env bash
set -euo pipefail

N=${NEVT:-100}
P=${MOMENTUM:-10}

for R in 1 5 10 20 30 50 75 100 150 200 300 400 500 750 1000 1250 1500; do
  ./run_point.sh "$R" "$N" "$P"
done
