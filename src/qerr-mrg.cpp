#include <iostream>
/*
    This is to merge the several lines, here it is 3, into one line.
    each of the 3 lines was the every 3rd locus imputation rightness.
*/
using namespace std;

int main(int argc, char*argv[]){
    ios_base::sync_with_stdio(false);
    if(argc!=2){
        cerr<<"Usage: cat rst.txt | "<<argv[0]<<" ncycle\n";
        return 1;
    }

    int ntt(stoi(argv[1]));
    string row[ntt];
    while(cin>>row[0]){
        for(auto i{1}; i<ntt; ++i) cin>>row[i];
        size_t i{0}, len(row[0].length()-1);
        for(; i<row[ntt-1].length(); ++i){
            for(auto j{0}; j<ntt; ++j) cout<<row[j][i];
        }
        for(auto j{0}; j<ntt; ++j) if(row[j].length()>i) cout<<row[j][len];
        cout<<'\n';
    }
    return 0;
}