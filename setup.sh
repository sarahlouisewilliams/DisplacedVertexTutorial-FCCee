#!/usr/bin/env bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "ERROR: run this as: source setup.sh"
  exit 1
fi

# If the caller has not already sourced a Key4hep environment, use the nightly.
if ! command -v ddsim >/dev/null 2>&1; then
  source /cvmfs/sw-nightlies.hsf.org/key4hep/setup.sh
fi


export DETECTOR="${K4GEO}/FCCee/CLD/compact/CLD_o2_v07/CLD_o2_v07.xml"
if [[ ! -f "$DETECTOR" ]]; then echo "ERROR: $DETECTOR not found"; exit 1; fi
if [[ ! -d CLDConfig ]]; then echo "CLDConfig not found, please clone from gitlab through git clone https://github.com/key4hep/CLDConfig.git; "; fi
if [[ ! -d k4Reco ]]; then echo "k4Reco not found, please clone from gitlab through git clone https://github.com/key4hep/k4Reco.git; "; fi


echo "ddsim: $(command -v ddsim)"
echo "HepMC3-config: $(command -v HepMC3-config)"
echo "HepMC3 version: $(HepMC3-config --version)"
echo "DETECTOR=$DETECTOR"
echo "CLDConfig commit: $(git -C CLDConfig rev-parse HEAD)"
