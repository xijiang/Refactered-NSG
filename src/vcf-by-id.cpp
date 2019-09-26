#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <set>
#include <vector>

using namespace std;
class VCF{
public:
  vector<string> header, chromosome, BP, SNP, ID;
  string REF, ALT;
  map<string, string> gt;
  void read(istream&in){
    string line;
    // Header
    while(getline(in, line)){
      if(line[1]!='#'){
	stringstream ss(line);
	string id;
	for(auto i{0}; i<9; ++i) ss>>id;
	while(ss>>id) ID.push_back(id);
	break;
      }
      header.push_back(line.substr(2));
    }
    for(string line; getline(in, line);){
      stringstream ss(line);
      string chr, bp, snp, sdm;
      char   ref, alt, cdm;
      ss>>chr>>bp>>snp>>ref>>alt>>cdm>>sdm>>cdm>>sdm;
      chromosome.push_back(chr);
      BP.push_back(bp);
      SNP.push_back(snp);
      REF+=ref;
      ALT+=alt;
      for(const auto&id:ID){
	ss>>sdm;
	gt[id]+=sdm;
      }
    }
  }
  void write(ostream&oo){	// This is to reproduce
    for(const auto&line:header) oo<<"##"<<line<<'\n';
    oo<<"#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT";
    for(const auto&id:ID) oo<<'\t'<<id;
    oo<<'\n';
    for(size_t i{0}; i<chromosome.size(); ++i){
      oo<<chromosome[i]<<'\t'<<BP[i]<<'\t'<<SNP[i]<<'\t'<<REF[i]<<'\t'<<ALT[i];
      oo<<"\t.\tPASS\t.\tGT";
      for(const auto&id:ID) oo<<'\t'<<gt[id].substr(i*3, 3);
      oo<<'\n';
    }
  }
  void write(ostream&oo, const set<string>&sid){
    for(const auto&line:header) oo<<"##"<<line<<'\n';
    oo<<"#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT";
    for(const auto&id:sid) oo<<'\t'<<id;
    oo<<'\n';
    for(size_t i{0}; i<chromosome.size(); ++i){
      oo<<chromosome[i]<<'\t'<<BP[i]<<'\t'<<SNP[i]<<'\t'<<REF[i]<<'\t'<<ALT[i];
      oo<<"\t.\tPASS\t.\tGT";
      for(const auto&id:sid) oo<<'\t'<<gt[id].substr(i*3, 3);
      oo<<'\n';
    }
  }
};
  
int main(int argc, char *argv[])
{
  if(argc!=2){
    cerr<<"Usage: zcat chr.vcf.gz | "<<argv[0]<<" id-list\n";
    return 1;
  }
  ios_base::sync_with_stdio(false); // avoid significant overhead
  VCF vcf;
  vcf.read(cin);
  set<string> tid, sid;
  for(const auto&id:vcf.ID) tid.insert(id);
  ifstream fin(argv[1]);
  for(string id; fin>>id;){
    if(tid.find(id)==tid.end()){
      cerr<<"ID "<<id<<" not in the VCF file\n";
      return 2;
    }
    sid.insert(id);
  }
  //vcf.write(cout);
  vcf.write(cout, sid);
  return 0;
}
