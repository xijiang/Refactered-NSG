#include <iostream>
#include <fstream>
#include <set>
/**
 * Given an (ordered) map from stdin, and the file name of a set of SNP,
 * this program prints the sub-map of the SNP set.
 *
 * Usage: cat map | this-program snp-set
 */
using namespace std;

int main(int argc, char *argv[])
{
  set<string> snps;
  ifstream fin(argv[1]);
  for(string snp; fin>>snp; snps.insert(snp));
  for(string snp, chr, bp; cin>>snp>>chr>>bp;)
    if(snps.find(snp) != snps.end())
      cout<<snp<<'\t'<<chr<<'\t'<<bp<<'\n';
  return 0;
}
