#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

/**
 * This is to compare 3 files: imp, msk, and ori
 * With imp and msk to determine which is masked
 * With imp and ori to determine if the imputation is right.
 */

using namespace std;

void skip_header(istream&in, string&line){ // line will contain ID info when return.
  for(char ch; in>>ch; ){
    if(ch == '#') getline(in, line);
    else{
      in.putback(ch);
      return;
    }
  }
}

void skip_pre(stringstream&ss, string&snp){
  string dum;
  ss>>dum>>dum>>snp;
  for(auto i{3}; i<9; ++i) ss>>dum;
  return;
}

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if(argc!=4){
    cerr<<"Usage: "<<argv[0]<<"ori.vcf msk.vcf imp.vcf >result\n";
    return 1;
  }
  ifstream ori(argv[1]), msk(argv[2]), imp(argv[3]);
  string line, snp;
  vector<string> ID;
  
  skip_header(ori, line);
  skip_header(msk, line);
  skip_header(imp, line);
  {				// extract ID info
    stringstream ss(line);
    string id;
    for(auto i{0}; i<9; ++i) ss>>id;
    while(ss>>id) ID.push_back(id);
  }

  while(getline(ori, line)){
    stringstream sa(line);
    skip_pre(sa, snp);
    getline(msk, line);
    stringstream sb(line);
    skip_pre(sb, snp);
    getline(imp, line);
    stringstream sc(line);
    skip_pre(sc, snp);

    int id=0;
    string ga, gb, gc;
    while(sa>>ga){
      sb>>gb;
      sc>>gc;
      if(gb[0] == '.' && ga[0] != '.'){ // a masked point
	cout<<snp<<' '<<ID[id];
	if( (ga[0] == gc[0] && ga[2] == gc[2]) ||
	    (ga[0] == gc[2] && ga[2] == gc[0])) cout << " 0\n";
	else cout << " 1\n";
      }
      ++id;
    }
  }
  return 0;
}
