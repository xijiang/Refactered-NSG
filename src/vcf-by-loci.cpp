#include <iostream>
#include <fstream>
#include <sstream>
#include <set>

using namespace std;

int main(int argc, char *argv[])
{
  set<string> small;
  ifstream fin(argv[1]);
  for(string snp; fin>>snp; small.insert(snp));
  for(string line; getline(cin, line); ){
    if(line[0]=='#'){
      cout<<line<<'\n';
      continue;
    }
    stringstream ss(line);
    string chr, bp, snp;
    ss>>chr>>bp>>snp;
    if(small.find(snp)!=small.end()) cout<<line<<'\n';
  }
  return 0;
}
