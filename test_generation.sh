#!/bin/bash

[[ -x ./generate_dv_sample ]] || ./build_generator.sh

rm -f test_dv.hepmc3

./generate_dv_sample \
  --nev 2 \
  --radius 100 \
  --momentum 10 \
  --seed 12345 \
  --output test_dv.hepmc3

echo
echo "=== First 30 lines of generated HepMC3 ==="
head -30 test_dv.hepmc3

echo
echo "Generation test completed."
