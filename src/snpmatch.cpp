#include <iostream>
#include <fstream>
#include <set>

using namespace std;

int main(int argc, char *argv[])
{
  set<string> target;
  ifstream    fin(argv[1]);
  for(string snp; fin>>snp; target.insert(snp));
  string snp;
  int    chr, bp;
  while(cin>>snp>>chr>>bp)
    if(target.find(snp)!=target.end())
      cout<<snp<<'\t'<<chr<<'\t'<<bp<<'\n';
  
  return 0;
}
