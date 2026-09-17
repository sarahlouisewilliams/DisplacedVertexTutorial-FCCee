#include <TFile.h>
#include <TTree.h>
#include <TTreeFormula.h>

#include <iostream>
#include <fstream>
#include <iomanip>
#include <vector>
#include <string>

void analyse_radius_scan() {

    std::vector<int> radii = {
        0, 10, 20, 30, 40, 50, 60, 70,
        80, 90, 100, 120, 150, 200
    };

    std::ofstream out("radius_scan.csv");

    out << "radius_mm,"
        << "n_events,"
        << "n_tracks_total,"
        << "n_0track,"
        << "n_1track,"
        << "n_2plus,"
        << "mean_vxd_hits,"
        << "mean_inner_hits,"
        << "mean_outer_hits,"
        << "track_eff,"
        << "two_track_eff\n";

    std::cout
        << std::setw(8)  << "R [mm]"
        << std::setw(8)  << "Nev"
        << std::setw(10) << "Tracks"
        << std::setw(8)  << "N0"
        << std::setw(8)  << "N1"
        << std::setw(8)  << "N2+"
        << std::setw(10) << "<VXD>"
        << std::setw(10) << "<Inner>"
        << std::setw(10) << "<Outer>"
        << std::setw(12) << "trk eff"
        << std::setw(12) << "2trk eff"
        << "\n";

    for (int r : radii) {

        std::string filename =
            "dv_r" + std::to_string(r) + "_REC.edm4hep.root";

        TFile file(filename.c_str(), "READ");

        if (file.IsZombie()) {
            std::cerr << "WARNING: cannot open "
                      << filename << "\n";
            continue;
        }

        TTree *events =
            dynamic_cast<TTree*>(file.Get("events"));

        if (!events) {
            std::cerr << "WARNING: no events tree in "
                      << filename << "\n";
            continue;
        }

        //
        // TTreeFormula lets ROOT handle the PODIO
        // split collection representation for us.
        //
        TTreeFormula nCT(
            "nCT",
            "Length$(SiTracksCT.type)",
            events
        );

        TTreeFormula nVXD(
            "nVXD",
            "Length$(VXDTrackerHits.cellID)",
            events
        );

        TTreeFormula nInner(
            "nInner",
            "Length$(ITrackerHits.cellID)",
            events
        );

        TTreeFormula nOuter(
            "nOuter",
            "Length$(OTrackerHits.cellID)",
            events
        );

        Long64_t nev = events->GetEntries();

        long nTracksTotal = 0;
        long n0 = 0;
        long n1 = 0;
        long n2plus = 0;

        double sumVXD   = 0.0;
        double sumInner = 0.0;
        double sumOuter = 0.0;

        for (Long64_t i = 0; i < nev; ++i) {

            events->LoadTree(i);
            events->GetEntry(i);

            int nt =
                static_cast<int>(nCT.EvalInstance());

            int nvxd =
                static_cast<int>(nVXD.EvalInstance());

            int ninner =
                static_cast<int>(nInner.EvalInstance());

            int nouter =
                static_cast<int>(nOuter.EvalInstance());

            nTracksTotal += nt;

            if (nt == 0)
                ++n0;
            else if (nt == 1)
                ++n1;
            else
                ++n2plus;

            sumVXD   += nvxd;
            sumInner += ninner;
            sumOuter += nouter;
        }

        double meanVXD =
            nev ? sumVXD / nev : 0.0;

        double meanInner =
            nev ? sumInner / nev : 0.0;

        double meanOuter =
            nev ? sumOuter / nev : 0.0;

        //
        // Exactly two generated muons/event
        //
        double trackEff =
            nev ? double(nTracksTotal)/(2.0*nev) : 0.0;

        double twoTrackEff =
            nev ? double(n2plus)/double(nev) : 0.0;

        std::cout
            << std::setw(8)  << r
            << std::setw(8)  << nev
            << std::setw(10) << nTracksTotal
            << std::setw(8)  << n0
            << std::setw(8)  << n1
            << std::setw(8)  << n2plus
            << std::setw(10) << std::fixed
            << std::setprecision(1) << meanVXD
            << std::setw(10) << meanInner
            << std::setw(10) << meanOuter
            << std::setw(12) << std::setprecision(3)
            << trackEff
            << std::setw(12) << twoTrackEff
            << "\n";

        out
            << r << ","
            << nev << ","
            << nTracksTotal << ","
            << n0 << ","
            << n1 << ","
            << n2plus << ","
            << meanVXD << ","
            << meanInner << ","
            << meanOuter << ","
            << trackEff << ","
            << twoTrackEff << "\n";
    }

    out.close();

    std::cout << "\nWrote radius_scan.csv\n";
}