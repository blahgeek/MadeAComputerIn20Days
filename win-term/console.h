#include "head.h"
#include "controller.h"
#include <winsock.h>

const int SCRN_X = 80;
const int SCRN_Y = 100;
const int LimitConsoleBuffer = 4096;

struct ConsoleCommand;

class Console
{
	HANDLE hstdout;
	COORD scrn;
	CONSOLE_SCREEN_BUFFER_INFO sbinf;
	char buffer[LimitConsoleBuffer+1];

	SOCKET client;
	HANDLE comHandle;
	
	int mode;
	int curcom;
	int totalcom;
	int sizecom;
	char **comlist; //Ö®Ç°µÄÃüÁî
	int comNo;
	word dataSeg;

	Controller controller;

public:
	Console();	
private:
	void clearscrn();
	void gotoxy(int,int);
	void gotoxy_cur(int);
	void addcom(char*);
	char *getcom(int);
	void work();
	void parseAndRun(char [], int );

	int runHelp();
	int runViewTLB(int, char *[]);
	int runDelTLB(int, char *[]);
	int runAddTLB(int, char *[]);
	int runLoadFile(int, char *[]);

	int getInput();
	void workSim();
	void workCom();
	int sendChar(char);
	int recvChar(char&);
	int sendWord(word);
	int recvWord(word&);
	int kernelRun(char [],int order_len);
	int runR();
	int runInt();
	int runD(int argc, char* argv[64]);
	int runA(int argc, char* argv[64]);
	int runU(int argc, char* argv[64]);
	int runG(int argc, char* argv[64]);

	void outputErrorMsg(int errCode);
};

typedef void(Console::* ConsoleFunc) (int , char *[]);

struct ConsoleCommand
{
	ConsoleFunc func;
	char* funcName;
	char* funcDescription;
	
};