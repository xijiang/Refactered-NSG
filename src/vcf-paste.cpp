#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

void put_10(const string&line){
  stringstream ss(line);
  string t;
  for(auto i=0; i<9; ++i) ss>>t;
  getline(ss, t);
  cout<<t;
}

int main(int argc, char *argv[])
{
  if(argc<3){
    cerr<<"Usage: "<<argv[0]<<" 1.vcf 2.vcf ...\n";
    return 1;
  }
  
  int nf=argc-1;
  ifstream fin[nf];
  
  for(auto i{0}; i<nf; ++i){
    fin[i].open(argv[i+1]);
    string line;
    while(getline(fin[i], line)){
      if(line[1]!='#') break;
      if(i==0) cout<<line<<'\n';
    }
    if(i) put_10(line);
    else  cout<<line;
  }
  cout<<'\n';

  for(string line; getline(fin[0], line); cout<<'\n'){
    cout<<line;
    for(auto i{1}; i<nf; ++i){
      getline(fin[i], line);
      put_10(line);
    }
  }

  return 0;
}
