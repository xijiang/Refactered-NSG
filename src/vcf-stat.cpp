#include <iostream>
#include <sstream>
#include <vector>

using namespace std;
/*
    The total number of missing genotypes are accumulated in two rows
    The first row is for individuals
    The second row is for SNP loci.
*/
int main(int argc, char *argv[])
{
    ios_base::sync_with_stdio(false);
    string line, loc;
    vector<int> mid, mlc;

    getline(cin, line);
    {
        stringstream ss(line);
        for (auto i = 0; i < 9; ++i)
            ss >> loc;
        int tt{0};
        while (ss >> loc)
        {
            int ms = ((loc[0] == '.') ? 1 : 0);
            tt += ms;
            mid.push_back(ms);
        }
        mlc.push_back(tt);
    }
    while (getline(cin, line))
    {
        stringstream ss(line);
        for (auto i = 0; i < 9; ++i)
            ss >> loc;
        int tt{0};
        for (auto &x : mid)
        {
            ss >> loc;
            int ms = ((loc[0] == '.') ? 1 : 0);
            x += ms;
            tt += ms;
        }
        mlc.push_back(tt);
    }
    for (const auto &x : mid)
        cout << ' ' << x;
    cout << '\n';
    for (const auto &x : mlc)
        cout << ' ' << x;
    cout << '\n';

    return 0;
}