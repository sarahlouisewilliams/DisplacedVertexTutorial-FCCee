#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt

# ------------------------------------------------------------
# Read scan results
# ------------------------------------------------------------

df = pd.read_csv("radius_scan.csv")
df = df.sort_values("radius_mm")

print(df)

# ------------------------------------------------------------
# Plot 1: tracking efficiency vs displaced-vertex radius
# ------------------------------------------------------------

fig, ax = plt.subplots(figsize=(8, 5.5))

ax.plot(
    df["radius_mm"],
    df["track_eff"],
    marker="o",
    label="Single-track efficiency"
)

ax.plot(
    df["radius_mm"],
    df["two_track_eff"],
    marker="s",
    label="Two-track efficiency"
)

ax.set_xlabel("Truth DV radius [mm]")
ax.set_ylabel("Efficiency")

ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)
ax.legend()

fig.tight_layout()

fig.savefig("tracking_efficiency_vs_radius.pdf")
fig.savefig("tracking_efficiency_vs_radius.png", dpi=200)

plt.close(fig)

# ------------------------------------------------------------
# Plot 2: mean number of digitised tracker hits
# ------------------------------------------------------------

fig, ax = plt.subplots(figsize=(8, 5.5))

ax.plot(
    df["radius_mm"],
    df["mean_vxd_hits"],
    marker="o",
    label="Vertex detector"
)

ax.plot(
    df["radius_mm"],
    df["mean_inner_hits"],
    marker="s",
    label="Inner tracker"
)

ax.plot(
    df["radius_mm"],
    df["mean_outer_hits"],
    marker="^",
    label="Outer tracker"
)

ax.set_xlabel("Truth DV radius [mm]")
ax.set_ylabel("Mean digitised hits / event")

ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)
ax.legend()

fig.tight_layout()

fig.savefig("tracker_hits_vs_radius.pdf")
fig.savefig("tracker_hits_vs_radius.png", dpi=200)

plt.close(fig)

print()
print("Created:")
print("  tracking_efficiency_vs_radius.pdf")
print("  tracking_efficiency_vs_radius.png")
print("  tracker_hits_vs_radius.pdf")
print("  tracker_hits_vs_radius.png")

# ------------------------------------------------------------
# Plot 3: reconstructed-track multiplicity
# ------------------------------------------------------------

fig, ax = plt.subplots(figsize=(8, 5.5))

ax.plot(
    df["radius_mm"],
    df["n_0track"] / df["n_events"],
    marker="o",
    label="0 tracks"
)

ax.plot(
    df["radius_mm"],
    df["n_1track"] / df["n_events"],
    marker="s",
    label="1 track"
)

ax.plot(
    df["radius_mm"],
    df["n_2plus"] / df["n_events"],
    marker="^",
    label="2+ tracks"
)

ax.set_xlabel("Truth DV radius [mm]")
ax.set_ylabel("Fraction of events")

ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)
ax.legend()

fig.tight_layout()

fig.savefig("track_multiplicity_vs_radius.pdf")
fig.savefig("track_multiplicity_vs_radius.png", dpi=200)

print()
print("Created:")
print("  track_multiplicity_vs_radius.pdf")
print("  track_multiplicity_vs_radius.png")


plt.close(fig)