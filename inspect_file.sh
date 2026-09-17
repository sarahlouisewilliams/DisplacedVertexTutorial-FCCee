#!/usr/bin/env bash
F=${1:?Usage: ./inspect_file.sh FILE.edm4hep.root}
[[ -f "$F" ]] || { echo "ERROR: file not found: $F"; exit 1; }
podio-dump -l "$F"
