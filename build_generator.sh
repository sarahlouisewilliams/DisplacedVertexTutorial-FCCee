#!/usr/bin/env bash

command -v HepMC3-config >/dev/null 2>&1 || {
  echo "ERROR: HepMC3-config is not on PATH."
  echo "Source the Key4hep environment first."
  exit 1
}

echo "Using HepMC3 $(HepMC3-config --version)"
echo "Prefix: $(HepMC3-config --prefix)"

g++ -std=c++17 -O2 -Wall -Wextra \
  generate_dv_sample.cpp \
  $(HepMC3-config --cflags) \
  $(HepMC3-config --libs) \
  -Wl,-rpath,"$(HepMC3-config --libdir)" \
  -o generate_dv_sample

echo "Built: $(pwd)/generate_dv_sample"
