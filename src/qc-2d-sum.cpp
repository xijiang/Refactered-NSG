#include <iostream>
#include <fstream>
#include <tuple>
#include <map>

using namespace std;

using TID=tuple<int, double>;

inline TID& operator+=(TID&a, const TID&b){
  get<0>(a)+=get<0>(b);
  get<1>(a)+=get<1>(b);
  return a;
}

int main(int argc, char *argv[])
{
  map<string, TID> ID, SNP;
  int t;
  for(string id, snp; cin>>snp>>id>>t;){
    ID[id] += TID{1, t};
    SNP[snp] += TID{1, t};
  }

  ofstream foo("SNP.qc");
  foo<<fixed;
  foo.precision(12);
  
  for(auto&[snp, t]:SNP){
    auto&[cnt, err] = t;
    foo<<snp<<' '<<err/cnt<<'\n';
  }
  foo.close();

  foo.open("ID.qc");
  foo<<fixed;
  foo.precision(12);

  for(auto&[id, t]:ID){
    auto&[cnt, err] = t;
    foo<<id<<' '<<err/cnt<<'\n';
  }
  return 0;
}
