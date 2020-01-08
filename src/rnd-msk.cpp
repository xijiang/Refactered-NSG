#include <iostream>
#include <sstream>
#include <random>

/**
 * Randomly mask a point, i.e., SNP by ID genotype, with the given probability.
 */
using namespace std;

void bake_rng(mt19937&rng){
  random_device rdv;
  int           seeds[624];

  for(auto&x:seeds) x=rdv();
  seed_seq seq(seeds, seeds+624);
  rng.seed(seq);
}

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if(argc!=2){
    cerr<<"Usage: cat some.vcf | "<<argv[0]<<" prob-to-mask > target.vcf\n";
    return 1;
  }
  
  double pr(stof(argv[1]));
  if(pr<=0 || pr>=1){
    cerr<<"Probability should be in (0, 1)\n";
    return 2;
  }
  
  mt19937 rng;
  uniform_real_distribution<double> unif(0,1);
  bake_rng(rng);

  for(string line; getline(cin, line);){
    if(line[0] == '#'){
      cout<<line<<'\n';
      continue;
    }
    stringstream ss(line);
    string point;
    ss>>point;
    cout<<point;
    for(auto i{1}; i<9; ++i){
      ss>>point;
      cout<<'\t'<<point;
    }
    while(ss>>point){
      if(unif(rng) < pr) cout<<"\t./.";
      else cout<<'\t'<<point;
    }
    cout<<'\n';
  }
  
  return 0;
}
