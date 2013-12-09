#include <cstdio>
#include <cstdlib>
#include <string>
#include <windows.h>
#include <conio.h>
#include <cstring>
#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>

using namespace std;

typedef unsigned int word;

#define ConsoleCommandError 1
#define NoInstructionError 2
#define InvalidMemAddress 3
#define InvalidTLBIndex 4
#define OpenFileError 5
#define SocketError 6
#define ServerLostError 7
#define RecvError 8
#define SendError 9
#define NoJrRaError 10