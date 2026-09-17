#!/usr/bin/env python3
"""Generate a minimal HepMC2 ASCII sample containing one displaced mu+mu- vertex/event.

No pyhepmc dependency is required. The output is intended as input to DD4hep/ddsim.
Units are GeV and mm.
"""
import argparse
import math
import random
from pathlib import Path

MUON_MASS_GEV = 0.1056583755


def particle_line(barcode, pdg, px, py, pz, energy, mass, status=1):
    # HepMC2 ASCII P record:
    # P barcode pdg px py pz E m status theta phi end_vertex nflow
    return (
        f"P {barcode} {pdg} {px:.12e} {py:.12e} {pz:.12e} "
        f"{energy:.12e} {mass:.12e} {status} 0 0 0 0\n"
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nev", type=int, default=1000)
    parser.add_argument("--radius", type=float, default=100.0,
                        help="DV transverse radius [mm]")
    parser.add_argument("--z", type=float, default=0.0,
                        help="DV z coordinate [mm]")
    parser.add_argument("--momentum", type=float, default=10.0,
                        help="Muon momentum [GeV]")
    parser.add_argument("--opening", type=float, default=1.0,
                        help="Half-opening angle around outward radial direction [rad]")
    parser.add_argument("--seed", type=int, default=12345)
    parser.add_argument("--output", default="dv.hepmc")
    args = parser.parse_args()

    if args.nev <= 0:
        parser.error("--nev must be > 0")
    if args.radius < 0:
        parser.error("--radius must be >= 0")
    if args.momentum <= 0:
        parser.error("--momentum must be > 0")

    random.seed(args.seed)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    p = args.momentum
    energy = math.sqrt(p * p + MUON_MASS_GEV * MUON_MASS_GEV)

    with output.open("w", encoding="ascii") as out:
        out.write("HepMC::Version 2.06.11\n")
        out.write("HepMC::IO_GenEvent-START_EVENT_LISTING\n")

        for iev in range(args.nev):
            phi_vtx = random.uniform(0.0, 2.0 * math.pi)
            x = args.radius * math.cos(phi_vtx)
            y = args.radius * math.sin(phi_vtx)

            phi_minus = phi_vtx + args.opening
            phi_plus = phi_vtx - args.opening

            px_minus = p * math.cos(phi_minus)
            py_minus = p * math.sin(phi_minus)
            px_plus = p * math.cos(phi_plus)
            py_plus = p * math.sin(phi_plus)

            # Minimal HepMC2 event. Signal-process vertex barcode is -1.
            out.write(f"E {iev} -1 -1.0 -1.0 -1.0 0 0 1 0 0 0\n")
            out.write("U GEV MM\n")
            # V barcode status x y z t n_orphans n_out n_weights
            out.write(
                f"V -1 0 {x:.12e} {y:.12e} {args.z:.12e} 0.0 0 2 0\n"
            )
            out.write(particle_line(1, 13, px_minus, py_minus, 0.0,
                                    energy, MUON_MASS_GEV))
            out.write(particle_line(2, -13, px_plus, py_plus, 0.0,
                                    energy, MUON_MASS_GEV))

        out.write("HepMC::IO_GenEvent-END_EVENT_LISTING\n")

    print(f"Wrote {args.nev} events to {output}")
    print(f"  r_DV       = {args.radius} mm")
    print(f"  z_DV       = {args.z} mm")
    print(f"  p(mu)      = {args.momentum} GeV")
    print(f"  half-angle = {args.opening} rad")
    print("  format     = HepMC2 ASCII (no pyhepmc required)")


if __name__ == "__main__":
    main()
