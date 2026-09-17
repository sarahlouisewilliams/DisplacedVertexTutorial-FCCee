#include <HepMC3/GenEvent.h>
#include <HepMC3/GenParticle.h>
#include <HepMC3/GenVertex.h>
#include <HepMC3/WriterAscii.h>

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <random>
#include <string>

static void usage(const char* prog) {
  std::cerr << "Usage: " << prog
            << " --nev N --radius R_MM --momentum P_GEV --output FILE"
            << " [--z Z_MM] [--opening RAD] [--seed SEED]\n";
}

int main(int argc, char** argv) {
  int nev = 100;
  double radius = 100.0, z = 0.0, momentum = 10.0, opening = 1.0;
  unsigned long seed = 12345;
  std::string output = "dv.hepmc3";

  for (int i=1; i<argc; ++i) {
    std::string a=argv[i];
    auto next=[&]() {
      if (i+1>=argc) { usage(argv[0]); std::exit(2); }
      return std::string(argv[++i]);
    };
    if      (a=="--nev")      nev=std::stoi(next());
    else if (a=="--radius")   radius=std::stod(next());
    else if (a=="--z")        z=std::stod(next());
    else if (a=="--momentum") momentum=std::stod(next());
    else if (a=="--opening")  opening=std::stod(next());
    else if (a=="--seed")     seed=std::stoul(next());
    else if (a=="--output")   output=next();
    else if (a=="-h" || a=="--help") { usage(argv[0]); return 0; }
    else { std::cerr<<"Unknown option: "<<a<<"\n"; usage(argv[0]); return 2; }
  }

  constexpr double mmu=0.1056583755;
  constexpr int parent_pdg=9900012; // generator-level dummy LLP
  std::mt19937_64 rng(seed);
  std::uniform_real_distribution<double> phi_dist(0.0,2.0*M_PI);

  HepMC3::WriterAscii writer(output);
  if (writer.failed()) { std::cerr<<"ERROR opening "<<output<<"\n"; return 1; }

  for (int iev=0; iev<nev; ++iev) {
    HepMC3::GenEvent evt(HepMC3::Units::GEV,HepMC3::Units::MM);
    evt.set_event_number(iev);

    const double phi_v=phi_dist(rng);
    const double x=radius*std::cos(phi_v), y=radius*std::sin(phi_v);
    auto dv=std::make_shared<HepMC3::GenVertex>(HepMC3::FourVector(x,y,z,0.0));

    const double E=std::sqrt(momentum*momentum+mmu*mmu);
    const double phi1=phi_v+opening, phi2=phi_v-opening;

    const HepMC3::FourVector p1(momentum*std::cos(phi1),
                                momentum*std::sin(phi1),0.0,E);
    const HepMC3::FourVector p2(momentum*std::cos(phi2),
                                momentum*std::sin(phi2),0.0,E);

    auto mu_minus=std::make_shared<HepMC3::GenParticle>(p1,13,1);
    auto mu_plus =std::make_shared<HepMC3::GenParticle>(p2,-13,1);

    // Give the displaced vertex an incoming generator-level parent.
    // Its four-momentum is exactly the sum of the daughters, so the
    // decay vertex conserves four-momentum. Status 2 marks it as decayed.
    HepMC3::FourVector pparent(p1.px()+p2.px(), p1.py()+p2.py(),
                               p1.pz()+p2.pz(), p1.e()+p2.e());
    auto parent=std::make_shared<HepMC3::GenParticle>(pparent,parent_pdg,2);

    dv->add_particle_in(parent);
    dv->add_particle_out(mu_minus);
    dv->add_particle_out(mu_plus);
    evt.add_vertex(dv);

    writer.write_event(evt);
    if (writer.failed()) { std::cerr<<"ERROR writing event "<<iev<<"\n"; return 1; }
  }

  writer.close();
  std::cout<<"Wrote "<<nev<<" events to "<<output<<"\n";
  std::cout<<"Each DV has one incoming status-2 parent (PDG "<<parent_pdg
           <<") and outgoing mu+ mu-.\n";
  return 0;
}
