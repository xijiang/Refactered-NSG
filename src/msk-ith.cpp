#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;
/*
    Specify every tt loci to be masked, start from ith
    e.g., 0 3.  means to mask every third loci and start from 0
*/
int main(int argc, char*argv[]){
    ios_base::sync_with_stdio(false);
    if(argc!=3){
        cerr<<"Usage: cat cmp.vcf "<< argv[0] << " a t | gzip -c >msk.vcf.gz\n";
        cerr<<"where a==0..t-1\n";
        cerr<<"t: to mask loci every t-th";
        return 1;
    }
    int ith(stoi(argv[1])), tt(stoi(argv[2])), cnt{-1};
    ofstream foo("imputed.snp");
    
    if(ith<0 || ith>=tt || tt<2){
        cerr<<"Wrong mask description\n";
        return 2;
    }
    for(string line; getline(cin, line);){
        if(line[0] == '#') {
            cout<<line<<'\n';
            continue;
        }
        ++cnt;
        if(cnt%tt == ith){
            stringstream ss(line);
            string seg;
            ss>>seg;
            cout<<seg;
            for(auto i{1}; i<9; ++i) {
                ss>>seg;
                cout<<'\t'<<seg;
		if(i==2) foo<<seg<<'\n';
            }
            while(ss>>seg) cout<<"\t./.";
            cout<<'\n';
        }
        cout<<line<<'\n';
    }
}
