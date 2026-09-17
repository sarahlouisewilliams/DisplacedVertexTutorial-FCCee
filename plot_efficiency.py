#!/usr/bin/env python3
import argparse
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

p = argparse.ArgumentParser()
p.add_argument("input")
p.add_argument("--output", default="dv_efficiency.pdf")
a = p.parse_args()

d = pd.read_csv(a.input)

def safe_ratio(num, den):
    return np.divide(num, den,
                     out=np.full(len(d), np.nan, dtype=float),
                     where=np.asarray(den) != 0)

d["eff_tracks"] = safe_ratio(d.n_2tracks, d.n_gen)
d["eff_vertex_given_tracks"] = safe_ratio(d.n_vertex, d.n_2tracks)
d["eff_dv"] = safe_ratio(d.n_vertex, d.n_gen)

plt.figure(figsize=(8, 5))
plt.plot(d.radius, d.eff_tracks, "o-", label="Both tracks reconstructed")
plt.plot(d.radius, d.eff_vertex_given_tracks, "s-", label="Vertex | tracks")
plt.plot(d.radius, d.eff_dv, "^-", label="Overall DV")
plt.xlabel(r"Truth DV radius $r_{\rm DV}$ [mm]")
plt.ylabel("Efficiency")
plt.ylim(0, 1.05)
plt.grid(alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(a.output)
print(a.output)
