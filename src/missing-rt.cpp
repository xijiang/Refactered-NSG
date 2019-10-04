#include <iostream>
#include <sstream>

using namespace std;
int main(int argc, char *argv[])
{
  double T{0}, miss{0}, nid{0}, nlc{0};
  for(string line; getline(cin, line);){
    if(line[0]=='#') continue;
    stringstream ss(line);
    string       gt;
    ++nlc;
    for(auto i=0; i<9; ++i) ss>>gt;
    while(ss>>gt){
      ++T;
      if(gt[0]=='.' || gt[2]=='.') ++miss;
    }
  }
  nid = T/nlc;
  clog<<"      Total ID: "<<static_cast<int>(nid )<<'\n';
  clog<<"    Total loci: "<<static_cast<int>(nlc )<<'\n';
  clog<<"Total genotype: "<<static_cast<int>(T   )<<'\n';
  clog<<" Total missing: "<<static_cast<int>(miss)<<'\n';
  cout<<miss/T<<endl;
  return 0;
}
