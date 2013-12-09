#include "controller.h"
#include "tool.h"


Controller::Controller(){
	AsmInstruction asmIR[] = {
		{"addiu",9,64,&Controller::asmFunc_2},
		{"addu",0,33,&Controller::asmFunc_1},
		{"slt",0,42,&Controller::asmFunc_1},
		{"slti",10,64,&Controller::asmFunc_2},
		{"sltiu",11,64,&Controller::asmFunc_2},
		{"sltu",0,43,&Controller::asmFunc_1},
		{"subu",0,35,&Controller::asmFunc_1},
		{"mult",0,24,&Controller::asmFunc_3},
		{"mflo",0,18,&Controller::asmFunc_3},
		{"mfhi",0,16,&Controller::asmFunc_3},
		{"mtlo",0,19,&Controller::asmFunc_3},
		{"mthi",0,17,&Controller::asmFunc_3},
		{"beq",4,64,&Controller::asmFunc_4},
		{"bgez",1,64,&Controller::asmFunc_4},
		{"bgtz",7,64,&Controller::asmFunc_4},
		{"blez",6,64,&Controller::asmFunc_4},
		{"bltz",1,64,&Controller::asmFunc_4},
		{"bne",5,64,&Controller::asmFunc_4},
		{"j",2,64,&Controller::asmFunc_5},
		{"jal",3,64,&Controller::asmFunc_5},
		{"jalr",0,9,&Controller::asmFunc_6},
		{"jr",0,8,&Controller::asmFunc_6},
		{"lw",35,64,&Controller::asmFunc_7},
		{"sw",43,64,&Controller::asmFunc_7},
		{"lb",32,64,&Controller::asmFunc_7},
		{"lbu",36,64,&Controller::asmFunc_7},
		{"sb",40,64,&Controller::asmFunc_7},
		{"and",0,36,&Controller::asmFunc_8},
		{"andi",12,64,&Controller::asmFunc_9},
		{"lui",15,64,&Controller::asmFunc_9},
		{"nor",0,39,&Controller::asmFunc_8},
		{"or",0,37,&Controller::asmFunc_8},
		{"ori",13,64,&Controller::asmFunc_9},
		{"xor",0,38,&Controller::asmFunc_8},
		{"xori",14,64,&Controller::asmFunc_9},
		{"sll",0,0,&Controller::asmFunc_10},
		{"sllv",0,4,&Controller::asmFunc_10},
		{"sra",0,3,&Controller::asmFunc_10},
		{"srav",0,7,&Controller::asmFunc_10},
		{"srl",0,2,&Controller::asmFunc_10},
		{"srlv",0,6,&Controller::asmFunc_10},
		{"syscall",0,14,&Controller::asmFunc_12},
		{"cache",47,64,&Controller::asmFuncNop},
		{"eret",16,24,&Controller::asmFunc_12},
		{"mfc0",16,0,&Controller::asmFunc_11},
		{"mtc0",16,0,&Controller::asmFunc_11},
		{"tlbwi",16,2},
		{"nop",0,0,&Controller::asmFuncNop}
	};

	triRegAsm.insert("addu");
	triRegAsm.insert("slt");
	triRegAsm.insert("sltu");
	triRegAsm.insert("subu");
	triRegAsm.insert("and");
	triRegAsm.insert("nor");
	triRegAsm.insert("or");
	triRegAsm.insert("xor");
	triRegAsm.insert("sllv"); //special
	triRegAsm.insert("srav"); //special
	triRegAsm.insert("srl");  //special
	triRegAsm.insert("srlv"); //special

	instantAsm.insert("addiu");
	instantAsm.insert("slti");
	instantAsm.insert("sltiu");
	instantAsm.insert("beq");
	instantAsm.insert("bne");
	instantAsm.insert("lw");  
	instantAsm.insert("sw");  
	instantAsm.insert("lb");  
	instantAsm.insert("lbu"); 
	instantAsm.insert("sb");  
	instantAsm.insert("andi");
	instantAsm.insert("ori"); 
	instantAsm.insert("xori");
	instantAsm.insert("lui"); 
	instantAsm.insert("beq"); 
	instantAsm.insert("bgez"); 
	instantAsm.insert("bgtz"); 
	instantAsm.insert("blez"); 
	instantAsm.insert("bne"); 
	instantAsm.insert("cache"); 

	int asmNum = sizeof(asmIR)/sizeof(AsmInstruction);

	for (int i=0;i<asmNum;i++){
		name2Asm[asmIR[i].name] = asmIR[i];
	}

	init();
	
}

void Controller::init(){
	regHeap.PC = 0xA0000000;
	for (int i=0;i<32;i++)
		regHeap.GPR[i] = 0;
	mem.init();
	
}

//addu slt sltu subu
void Controller::asmFunc_1(word command){
	int minorop = command & 0x0000003F;
	int s = (command >> 21) & 0x0000001F;
	int t = (command >> 16) & 0x0000001F;
	int d = (command >> 11) & 0x0000001F;

	switch(minorop){
		case 33:	//addu
			regHeap.GPR[d] = regHeap.GPR[s] + regHeap.GPR[t];
			break;
		case 42:	//slt
			regHeap.GPR[d] = ((int)regHeap.GPR[s]<(int)regHeap.GPR[t]) ? 1:0;
			break;
		case 43:	//sltu
			regHeap.GPR[d] = (regHeap.GPR[s]<regHeap.GPR[t]) ? 1:0;
			break;
		case 35:	//subu
			regHeap.GPR[d] = regHeap.GPR[s] - regHeap.GPR[t];
			break;
	}
	return;
}

//addiu slti sltiu
void Controller::asmFunc_2(word command){
	int op = command>>26;
	int s = (command >> 21) & 0x0000001F;
	int d = (command>>16) & 0x0000001F;
	int con = command & 0x0000FFFF;

	switch(op){
		case 9:		//addiu
			regHeap.GPR[d] = regHeap.GPR[s] + con;
			break;
		case 10:	//slti
			regHeap.GPR[d] = ((int)regHeap.GPR[s]<signalExtend16(con)) ? 1:0;
			break;
		case 11:	//sltiu
			regHeap.GPR[d] = (regHeap.GPR[s]<(word)con) ? 1:0;
			break;
	}
	return;
}

//mult mflo mfhi mtlo mthi
void Controller::asmFunc_3(word command){
	int minorop = command & 0x0000003F;
	int s = (command >> 21) & 0x0000001F;
	int t = (command >> 16) & 0x0000001F;
	int d = (command >> 11) & 0x0000001F;

	switch(minorop){
		case 16:	//mfhi
			regHeap.GPR[d] = regHeap.HI;
			break;
		case 17:	//mthi
			regHeap.HI = regHeap.GPR[s];
			break;
		case 18:	//mflo
			regHeap.GPR[d] = regHeap.LO;
			break;
		case 19:	//mtlo
			regHeap.LO = regHeap.GPR[s];
			break;
		case 24:	//mult
			long long result = ((int)regHeap.GPR[s])*((int)regHeap.GPR[t]);
			regHeap.HI = (result>>32);
			regHeap.LO = (result & 0x00000000FFFFFFFF);
			break;
	}
}

//beq bgez bgtz blez bltz bne
void Controller::asmFunc_4(word command){
	int op = command>>26;
	int offset = signalExtend16(command & 0x0000FFFF) * 4;
	int s = (command >> 21) & 0x0000001F;
	int t = (command >> 16) & 0x0000001F;

	switch (op)
	{
		case 1:		//bltz bgez
			if (t==0){
				if ((int)regHeap.GPR[s]<0) regHeap.PC += offset;
			}
			else    //bgez
			{
				if ((int)regHeap.GPR[s]>=0) regHeap.PC += offset;
			}
			break;
		case 4:		//beq
			if (regHeap.GPR[s]==regHeap.GPR[t]) regHeap.PC += offset;
			break;
		case 5:		//bne
			if (regHeap.GPR[s]!=regHeap.GPR[t]) regHeap.PC += offset;
			break;
		case 6:		//blez
			if ((int)regHeap.GPR[s]<=0) regHeap.PC += offset;
			break;
		case 7:		//bgtz
			if ((int)regHeap.GPR[s]>0) regHeap.PC += offset;
			break;
	}
}

//todo: j jal
void Controller::asmFunc_5(word command){
	int op = command>>26;
	if (op==3) regHeap.GPR[31] = regHeap.PC;
	regHeap.PC = (regHeap.PC & 0xF0000000) | ((command & 0x03FFFFFF)<<2);
}

//todo: jr jalr
void Controller::asmFunc_6(word command){
	int d = (command>>11) & 0x0000001F;
	int s = (command>>21) & 0x0000001F;
	int minorop = command & 0x0000003F;
	if (minorop == 9) regHeap.GPR[d] = regHeap.PC;
	regHeap.PC = regHeap.GPR[s];
}

//lw sw lb lbu sb
void Controller::asmFunc_7(word command){
	int op = command>>26;
	int b = (command>>21) & 0x0000001F;
	int t = (command>>16) & 0x0000001F;
	int offset = signalExtend16(command & 0x0000FFFF);
	switch(op){
		case 32:	//lb
			regHeap.GPR[t] = signalExtend8(mem.readByte(regHeap.GPR[b]+offset));
			break;
		case 35:	//lw
			regHeap.GPR[t] = mem.readWord(regHeap.GPR[b]+offset);
			break;
		case 36:	//lbu
			regHeap.GPR[t] = mem.readByte(regHeap.GPR[b]+offset);
			break;
		case 40:	//sb
			mem.writeByte(regHeap.GPR[b]+offset, regHeap.GPR[t]);
			break;
		case 43:	//sw
			mem.writeWord(regHeap.GPR[b]+offset, regHeap.GPR[t]);
			break;
	}
}

//and nor or xor
void Controller::asmFunc_8(word command){
	int minorop = command & 0x0000003F;
	int s = (command >> 21) & 0x0000001F;
	int t = (command >> 16) & 0x0000001F;
	int d = (command >> 11) & 0x0000001F;

	switch(minorop){
		case 36:	//and
			regHeap.GPR[d] = regHeap.GPR[s] & regHeap.GPR[t];
			break;
		case 37:	//or
			regHeap.GPR[d] = regHeap.GPR[s] | regHeap.GPR[t];
			break;
		case 38:	//xor
			regHeap.GPR[d] = regHeap.GPR[s] ^ regHeap.GPR[t];
			break;
		case 39:	//nor
			regHeap.GPR[d] = ~(regHeap.GPR[s] | regHeap.GPR[t]);
			break;
	}
	return;
}

//andi lui ori xori
void Controller::asmFunc_9(word command){
	int op = command>>26;
	int s = (command >> 21) & 0x0000001F;
	int d = (command>>16) & 0x0000001F;
	int con = command & 0x0000FFFF;

	switch(op){
		case 12:	//andi
			regHeap.GPR[d] = regHeap.GPR[s] & con;
			break;
		case 13:	//ori
			regHeap.GPR[d] = regHeap.GPR[s] | con;
			break;
		case 14:	//xori
			regHeap.GPR[d] = regHeap.GPR[s] ^ con;;
			break;
		case 15:	//lui
			regHeap.GPR[d] = con<<16;
			break;
	}
	return;
}

//todo:sll sllv sra srav srl srlv
void Controller::asmFunc_10(word command){
	int minorop = command & 0x0000003F;
	int s = (command >> 21) & 0x0000001F;
	int t = (command >> 16) & 0x0000001F;
	int d = (command >> 11) & 0x0000001F;
	int sa = (command >> 6) & 0x0000001F;

	switch(minorop){
		case 0:		//sll
			regHeap.GPR[t] = regHeap.GPR[d] << sa;
			break;
		case 2:		//srl
			regHeap.GPR[t] = regHeap.GPR[d] >> sa;
			break;
		case 3:		//sra
			regHeap.GPR[t] = (int)regHeap.GPR[d] >> sa;
			break;
		case 4:		//sllv
			regHeap.GPR[t] = regHeap.GPR[d] << (regHeap.GPR[s]%32);
			break;
		case 6:		//srlv
			regHeap.GPR[t] = regHeap.GPR[d] >> (regHeap.GPR[s]%32);
			break;
		case 7:		//srav
			regHeap.GPR[t] = (int)regHeap.GPR[d] >> (regHeap.GPR[s]%32);
			break;
	}

}

//mfc0 mtc0
void Controller::asmFunc_11(word command){
	int t = (command>>16) & 0x0000001F;
	int cr = (command>>11) & 0x0000001F;
	int flag = (command>>21) & 0x0000001F;
	if (flag==0)	//mfc0
		regHeap.GPR[t] = regHeap.CPR[cr];
	else            //mtc0
		regHeap.CPR[cr] = regHeap.GPR[t];
	return;
}

//eret syscall
void Controller::asmFunc_12(word command){

}


//nop
void Controller::asmFuncNop(word command){
	return;
}

//将汇编指令翻译成机器码
//to do: 0xabcd 怎么表示负数
word Controller::assemble(char command[]){
	const word RET_ERROR =  4294967295;

	int target,d,s,t,sa;

	command = _strlwr(command);

	char *argv[64];
	int argc = 0;
	int in_command = 0;
	for (int i=0;command[i] != '\0';i++)
	{
		if (command[i] != ' ' && command[i] != ',' && command[i]!= '(' && command[i]!= ')')
		{
			if (in_command == 0)
				argv[argc++] = &command[i];
			in_command = 1;
		}
		else
		{
			command[i] = '\0';
			in_command = 0;
		}
	}

	/*for (int i=0;i<argc;i++){
		cout<<argv[i]<<endl;
	}*/

    if (argc==0) return RET_ERROR;

	if (name2Asm.find(argv[0]) == name2Asm.end()) return RET_ERROR;

	AsmInstruction cntAsmIR = name2Asm[argv[0]];

	//nop
	if (cntAsmIR.name.compare("nop")==0) return 0;

	//j jal
	if (cntAsmIR.op == 2 || cntAsmIR.op == 3){
		if (argc !=2) return RET_ERROR;
		if (string2num(argv[1],target)){
			if (target<0 || target> 67108863) return RET_ERROR;
			return (cntAsmIR.op << 26) | target;
		}
		else
			return RET_ERROR;
	}

	//triple Register Asm
	if (triRegAsm.find(cntAsmIR.name)!=triRegAsm.end()){
		if (argc!=4) return RET_ERROR;
		if (string2reg(argv[1],d) && string2reg(argv[2],s) && string2reg(argv[3],t)){
			if (cntAsmIR.minorop == 2 || cntAsmIR.minorop == 4 || cntAsmIR.minorop == 6 || cntAsmIR.minorop == 7){
				sa = s;
				s = t;
				t = sa;
			}
			return (cntAsmIR.op << 26) | (s << 21) | (t << 16) | (d << 11) | cntAsmIR.minorop;
		}
		else 
			return RET_ERROR;
	}
	//Instant Asm
	if (instantAsm.find(cntAsmIR.name)!=instantAsm.end()){
		int argu1,argu2,argu3;
		switch(cntAsmIR.op){
			case 35:      //LW
			case 43:      //SW
			case 32:      //LB
			case 36:      //LBU
			case 40:      //SB
				if (argc!=4) return RET_ERROR;
				if (string2reg(argv[1],argu2) && string2reg(argv[3],argu1) && string2signed16(argv[2],argu3)){
					argu3 = argu3 & (0x0000FFFF);
				}
				else{
					return RET_ERROR;
				}
				break;
			case 9:       //addiu
			case 10:      //slti
				if (argc!=4) return RET_ERROR;
				if (string2reg(argv[1],argu2) && string2reg(argv[2],argu1) && string2signed16(argv[3],argu3)){
					argu3 = argu3 & (0x0000FFFF);
				}
				else{
					return RET_ERROR;
				}
				break;
			case 11:      //sltiu
			case 12:      //andi
			case 13:      //ori
			case 14:      //xori
				if (argc!=4) return RET_ERROR;
				if (string2reg(argv[1],argu2) && string2reg(argv[2],argu1) && string2usigned16(argv[3],argu3)){
				}
				else{
					return RET_ERROR;
				}
				break;
			case 15:     //lui
				if (argc!=3) return RET_ERROR;
				if (string2reg(argv[1],argu2) && string2usigned16(argv[2],argu3)){
					argu1 = 0;
				}
				else{
					return RET_ERROR;
				}
				break;
			case 4:      //beq
			case 5:      //bne
				if (argc == 4 && string2reg(argv[1],argu1) && string2reg(argv[2],argu2) && string2signed16(argv[3],argu3)){
					argu3 = argu3 & (0x0000FFFF);
				}
				else{
					return RET_ERROR;
				}
				break;
			case 1:      //bgez,bltz
			case 7:      //bgtz
			case 6:      //blez
				if (argc == 3 && string2reg(argv[1],argu1) && string2signed16(argv[2],argu3)){
					argu3 = argu3 & (0x0000FFFF);
					if (cntAsmIR.name.compare("bgez")==0)
						argu2 = 1;
					else
						argu2 = 0;
				}
				else{
					return RET_ERROR;
				}
				break;
			case 47:     //cache
				if (argc==4 && string2reg(argv[3],argu1) && string2num(argv[1],argu2) && string2signed16(argv[2],argu3)){
					argu3 = argu3 & (0x0000FFFF);
					if (argu2>31) return RET_ERROR;
				}
				else{
					return RET_ERROR;
				}
				break;
		}
		return (cntAsmIR.op<<26) | (argu1<<21) | (argu2<<16) | argu3;
	}
	
	if (cntAsmIR.name.compare("syscall")==0){
		int code;
		if (argc==2 && string2num(argv[1],code) && code<32 && code>=0){
			return (code<<6) | 12;
		}else if (argc==1){
			return 12;
		}
		else{
			return RET_ERROR;
		}
	}

	if (cntAsmIR.op==16){
		int part1,part2,part3,part4;
		if (cntAsmIR.minorop ==0){//mfc0 mtc0
			if (argc == 3 && string2reg(argv[1],part2) && string2reg(argv[2],part3)){
				part4 = 0;
				if (cntAsmIR.name.compare("mfc0")==0) 
					part1 = 0;
				else
					part1 = 4;
			}
			else{
				return RET_ERROR;
			}
		}//tlbwi  eret
		else{
			return (16<<26) | (16<<21) |(cntAsmIR.minorop);
		}
		return (part1<<21) | (part2<<16) | (part3<<11) | (part4<<6) | cntAsmIR.minorop;
	}
	else{
		int part1 = 0,part2 = 0,part3 = 0,part4 = 0;
		switch(cntAsmIR.minorop){
			case 24:      //mult
				if (argc==3 && string2reg(argv[2],part2) && string2reg(argv[1],part1)){
				}
				else{
					return RET_ERROR;
				}
				break;
			case 18:      //mflo
			case 16:      //mfhi
				if (argc==2 && string2reg(argv[1],part3)){
				}
				else{
					return RET_ERROR;
				}
				break;
			case 19:      //mtlo
			case 17:      //mthi
			case 8:       //jr
				if (argc==2 && string2reg(argv[1],part1)){
				}
				else{
					return RET_ERROR;
				}
				break;
			case 0:       //sll
			case 3:       //sra
				if (argc==4 && string2reg(argv[2],part2) && string2reg(argv[1],part3) && string2num(argv[3],part4)){
					if (part4>31 || part4<0) return RET_ERROR;
				}
				else{
					return RET_ERROR;
				}
				break;
			case 9:       //jalr
				if (argc==2 && string2reg(argv[1],part1)){
					part3=31;
				}
				else{
					if (argc==3 && string2reg(argv[1],part3) && string2reg(argv[2],part1)){
					}
					else{
						return RET_ERROR;
					}
				}
				break;
		}
		return (part1<<21) | (part2<<16) | (part3<<11) | (part4<<6) | cntAsmIR.minorop;
	}
	return RET_ERROR;
}

//将机器码翻译成汇编指令
string Controller::antiAssemble(word command){
	string GPRName[] = {"zero","at","v0","v1","a0","a1","a2","a3","t0","t1","t2","t3","t4","t5","t6","t7","s0"
						,"s1","s2","s3","s4","s5","s6","s7","t8","t9","k0","k1","gp","sp","s8","ra"};

	if (command==0) return "nop";
	if (command==0xFFFFFFFF) return "null";

    int op,minorop,part1,part2,part3,part4,offset;
	op = command>>26;
	minorop = command & 0x0000003F;
	part1 = (command>>21) & 0x0000001F;
	part2 = (command>>16) & 0x0000001F;
	part3 = (command>>11) & 0x0000001F;
	part4 = (command>>6) & 0x0000001F;
	offset = command & 0x0000FFFF;
	stringstream sstream;

	switch(op){
		case 1:
			if (part2==0)
				sstream<<"bltz\t$"<<GPRName[part1]<<", "<<signalExtend16(offset);
			else
				sstream<<"bgez\t$"<<GPRName[part1]<<", "<<signalExtend16(offset);
			break;
		case 2:
			sstream<<"j\t"<<(command & 0x03FFFFFF);
			break;
		case 3:
			sstream<<"jal\t"<<(command & 0x03FFFFFF);
			break;
		case 4:
			sstream<<"beq\t$"<<GPRName[part1]<<", $"<<GPRName[part2]<<", "<<signalExtend16(offset);
			break;
		case 5:
			sstream<<"bne\t$"<<GPRName[part1]<<", $"<<GPRName[part2]<<", "<<signalExtend16(offset);
			break;
		case 6:
			sstream<<"blez\t$"<<GPRName[part1]<<", "<<signalExtend16(offset);
			break;
		case 7:
			sstream<<"bgtz\t$"<<GPRName[part1]<<", "<<signalExtend16(offset);
			break;
		case 9:  
			sstream<<"addiu\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<signalExtend16(offset);
			break;
		case 10:
			sstream<<"slti\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<signalExtend16(offset);
			break;
		case 11:
			sstream<<"sltiu\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<offset;
			break;
		case 12:
			sstream<<"andi\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<offset;
			break;
		case 13:
			sstream<<"ori\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<offset;
			break;
		case 14:
			sstream<<"xori\t$"<<GPRName[part2]<<", $"<<GPRName[part1]<<", "<<offset;
			break;
		case 15:
			sstream<<"lui\t$"<<GPRName[part2]<<", "<<offset;
			break;

		case 16:
			if (part1==16){
				if (minorop==24) sstream<<"eret";
				if (minorop==2) sstream<<"tlbwi";
			}
			else{
				if (part1==0)
					sstream<<"mfc0\t$"<<GPRName[part2]<<", $"<<part3;
				else
					sstream<<"mtc0\t$"<<GPRName[part2]<<", $"<<part3;
			}
			break;
		case 32:
			sstream<<"lb \t$"<<GPRName[part2]<<", "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
		case 35:
			sstream<<"lw \t$"<<GPRName[part2]<<", "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
		case 36:
			sstream<<"lbu\t$"<<GPRName[part2]<<", "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
		case 40:
			sstream<<"sb \t$"<<GPRName[part2]<<", "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
		case 43:
			sstream<<"sw \t$"<<GPRName[part2]<<", "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
		case 47:
			sstream<<"cache\t"<<GPRName[part2]<<" "<<signalExtend16(offset)<<"($"<<GPRName[part1]<<")";
			break;
	}
	if (op==0){
		switch (minorop){
			case 0:
				sstream<<"sll\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", "<<part4;
				break;
			case 2:
				sstream<<"srl\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", $"<<GPRName[part1];
				break;
			case 3:
				sstream<<"sra\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", "<<part4;
				break;
			case 4:
				sstream<<"sllv\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", $"<<GPRName[part1];
				break;
			case 6:
				sstream<<"srav\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", $"<<GPRName[part1];
				break;
			case 7:
				sstream<<"srl\t$"<<GPRName[part3]<<", $"<<GPRName[part2]<<", $"<<GPRName[part1];
				break;
			case 8:
				sstream<<"jr\t$"<<GPRName[part1];
				break;
			case 9:
				sstream<<"jalr\t$"<<GPRName[part3]<<", $"<<GPRName[part1];
				break;
			case 12:   //to do
				sstream<<"syscall\t"<<((command>>6) & 0x000FFFFF);
				break;
			case 16:
				sstream<<"mfhi\t$"<<GPRName[part3];
				break;
			case 17:
				sstream<<"mthi\t$"<<GPRName[part1];
				break;
			case 18:
				sstream<<"mflo\t$"<<GPRName[part3];
				break;
			case 19:
				sstream<<"mtlo\t$"<<GPRName[part1];
				break;
			case 24:
				sstream<<"mult\t$"<<GPRName[part1]<<", $"<<GPRName[part2];
				break;
			case 33:
				sstream<<"addu\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 35:
				sstream<<"subu\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 36:
				sstream<<"and\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 37:
				sstream<<"or\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 38:
				sstream<<"xor\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 39:
				sstream<<"nor\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 42:
				sstream<<"slt\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
			case 43:
				sstream<<"sltu\t$"<<GPRName[part3]<<", $"<<GPRName[part1]<<",$"<<GPRName[part2];
				break;
		}
	}
	return sstream.str();
}
