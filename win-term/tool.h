#include "head.h"
bool string2num(char s[],int& result);

bool string2signed16(char s[],int& result);

bool string2usigned16(char s[],int& result);

bool string2dec(char s[],int& result);

bool string2hex(char s[],int& result);

bool string2reg(char s[],int& result);

int signalExtend16(int s);

int signalExtend8(int s);

bool string2addr(char s[],word& result);

void coutHexNum(word);

void coutBinNum(word);
