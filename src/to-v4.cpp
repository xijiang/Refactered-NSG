#include <iostream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  clog<<"Read 17k autosomal results\n";
  map<string, string> pre;
  string snp, gt;
  while(cin>>snp>>snp>>snp){
    getline(cin, gt);
    pre[snp] = gt;
  }

  clog<<"GT ordered with map v4\n";
  ifstream fin(argv[1]);
  int chr, bp;
  while(fin>>snp>>chr>>bp)
    if(pre.find(snp) != pre.end())
      cout<<chr<<'\t'<<bp<<'\t'<<snp<<pre[snp]<<'\n';
  return 0;
}
