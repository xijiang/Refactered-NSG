/**
 * read ID to mask and marker names on a sparse chip
 * Do the mask and output the masked vcf stream to stdout.
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <set>

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=2){
    cerr<<"Usage:\n";
    cerr<<"zcat chr.vcf.gz | " <<argv[0]<<" masked-snp-list\n";
    return 1;
  }

  ifstream fin(argv[1]);
  set<string> mskt;
  for(string snp; fin>>snp; mskt.insert(snp));

  for(string line; getline(cin, line);)
    if(line[1]!='#') break;	// Break @ the ID line

  for(string line; getline(cin, line);){
    stringstream ss(line);
    string  tstr[9];
    for(auto i=0; i<9; ++i) ss>>tstr[i];
    if(mskt.find(tstr[2])==mskt.end()) continue; // a shared locus
    else{
      cout<<tstr[2]<<'\t';
      for(string gt; ss>>gt; cout<<static_cast<char>(gt[0]-'0'+gt[2]));
      cout<<'\n';
    }
  }
    
  return 0;
}
