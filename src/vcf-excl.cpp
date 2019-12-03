#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if (argc != 2)
  {
    cerr << "Usage: zcat vcf.gz | " << argv[0] << " ID-name-to-be-tested\n";
    return 1;
  }
  string line, loc;
  string tid(argv[1]); // The test ID
  int iid{0};          //ID to be tested
  ofstream fout(string(argv[1])+".vcf");
  // Dealing with headers and find the position of the ID to be tested
  while (getline(cin, line))
  {
    if (line[1] != '#')
    {
      stringstream ss(line);
      // The first column, to avoid space in the beginning of lines
      ss >> loc;
      cout << loc;
      fout << loc;
      for (auto i{1}; i < 9; ++i)
      {
        ss >> loc;
        cout << '\t' << loc;
        fout << '\t' << loc;
      }
      fout << '\t' << tid << '\n';
      int xid{-1};
      while (ss >> loc)
      {
        ++xid;
        if (loc != tid)
          cout << '\t' << loc;
        else
          iid = xid;
      }
      cout << '\n';
      break;
    }
    else
    {
      cout << line << '\n';
      fout << line << '\n';
    }
  }
  while (getline(cin, line))
  {
    if (line[0] == '#')
      continue;
    stringstream ss(line);
    ss >> loc;
    cout << loc;
    fout << loc;
    for (auto i{1}; i < 9; ++i)
    {
      ss >> loc;
      cout << '\t' << loc;
      fout << '\t' << loc;
    }
    int xid{-1};
    while (ss >> loc)
    {
      ++xid;
      if (xid == iid)
        fout << '\t' << loc << '\n';
      else
        cout << '\t' << loc;
    }
    cout << '\n';
  }
  return 0;
}
