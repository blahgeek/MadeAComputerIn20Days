#ifndef _CONTROLLER_H_
#define _CONTROLLER_H_
#include "head.h"
#include "memory.h"
#include <map>
#include <set>

struct RegHeap{
	word CPR[32];   //Control Purpose Registers
	word GPR[32];   //General Purpose Registers
	word PC;
	word HI;
	word LO;
	word IR;        //Instruction Register
};

struct AsmInstruction;

class Controller{

public:
	RegHeap regHeap;
	Memory mem;
	map<string,AsmInstruction> name2Asm;
	set<string> triRegAsm;
	set<string> instantAsm;
	set<string> unRegAsm;

	Controller();
    
	void decode(word);
	word assemble(char []);
	string antiAssemble(word);

	void init();

	void asmFunc_1(word);
	void asmFunc_2(word);
	void asmFunc_3(word);
	void asmFunc_4(word);
	void asmFunc_5(word);
	void asmFunc_6(word);
	void asmFunc_7(word);
	void asmFunc_8(word);
	void asmFunc_9(word);
	void asmFunc_10(word);
	void asmFunc_11(word);
	void asmFunc_12(word);
	void asmFuncNop(word command);
};

typedef void(Controller::* AsmFunc) (word);

struct AsmInstruction{
	string name;
	word op;
	word minorop;
	AsmFunc asmFunc;
};


#endif