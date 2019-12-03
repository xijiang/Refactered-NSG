#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=4){
    cerr<<"Usage: \n";
    cerr<<"\t"<<argv[0]<<" cmp.gt imp.gt ids\n";
    return 1;
  }
  vector<string> ID;
  {
    ifstream fin(argv[3]);
    for(string id; fin>>id; ID.push_back(id));
  }

  ifstream cmp(argv[1]), imp(argv[2]);
  string sa, sb, ga, gb;
  while(cmp>>sa>>ga){
    imp>>sb>>gb;
    if(sa != sb){
      cerr<<"Wrong genotype files\n";
      return 2;
    }
    int i{0};
    for(auto id:ID){
      cout<<sa<<' '<<id<<' '<<((ga[i]==gb[i])?0:1) <<'\n';
      ++i;
    }
  }
  return 0;
}
