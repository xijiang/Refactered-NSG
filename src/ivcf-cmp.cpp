#include <iostream>

using namespace std;

int main(int argc, char*argv[]){
    int ith(stoi(argv[1])), tt(stoi(argv[2])), cnt{0};
    string a, b;
    while(cin>>a>>b){
        if(cnt%tt == ith){
            int x=a[0]-'0'+a[2];
            int y=b[0]-'0'+b[2];
            cout<<((x==y)?0:1);
        }
        ++cnt;
    }
    cout<<endl;
}
