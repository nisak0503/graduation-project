#include <iostream>
#include <cstdio>
#include <fstream>
#include <cmath>
#include <iomanip>
using namespace std;

ifstream fin("final_gps.txt");
ofstream fout("Annotations.plist");
void input()
{
  cout << "input()"<<endl;
  double hour, min, sec, latitude, longitude;
  int count = 0;
  while(fin >> hour)
  {
    count++;
    fin >> min >> sec >> longitude >> latitude;
    fout << " <dict>"<<endl;
    fout << "   <key>lat</key>"<<endl;
    fout <<setprecision(8)<< "   <real>"<<latitude<<"</real>"<<endl;
    fout << "   <key>long</key>"<<endl;
    fout << setprecision(8)<<"    <real>"<<longitude<<"</real>"<<endl;
    fout << "   <key>no</key>"<<endl;
    fout << "   <integer>"<<count<<"</integer>"<<endl;
    fout << "   <key>title</key>"<<endl;
    fout << "<string>hazard</string>"<<endl;
    fout << " </dict>"<<endl;
    //cout << setprecision(8)<<latitude << " "<<longitude<<endl;
  }
}

void cal()
{
  cout << "cal()"<<endl;
  fout << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"<<endl;
  fout << "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"<<endl;
  fout << "<plist version=\"1.0\">" << endl;
  fout << "<array>"<<endl;

  input();

  fout << "</array>" << endl;
  fout << "</plist>" << endl;
}

int main()
{
  //input();
  cal();
  return 0;
}