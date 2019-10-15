#include <iostream>

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
    int ith(stoi(argv[1])), tt(stoi(argv[2])), cnt{0};
    if(ith<0 || ith>=tt || tt<2){
        cerr<<"Wrong mask description\n";
        return 2;
    }
    for(string line; getline(cin, line);){
        if(line[0]!='#'){
            size_t len(line.length());
            if(cnt%tt == ith) line.replace(len-3, 3, "./.");
            else line[len-2]='/';
            ++cnt;
        }
        cout<<line<<'\n';
    }
}