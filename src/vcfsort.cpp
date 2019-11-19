#include <iostream>
#include <sstream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  map<string, string> gnt;
  int    ochr{0};
  string snp, gt, line;
  int    chr, bp;

  while(getline(cin, line)){
    stringstream ss(line);
    ss>>chr>>bp>>snp;
    getline(ss, line);
    gnt[snp] = line;
  }
  
  ifstream fin(argv[1]);
  ofstream foo;
  while(fin>>snp>>chr>>bp){
    if(chr != ochr){
      foo.close();
      foo.open(to_string(chr)+".vcf");
      ochr=chr;
    }
    foo<<chr<<'\t'<<bp<<'\t'<<snp<<gnt[snp]<<'\n';
  }
  return 0;
}
