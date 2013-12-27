#include "console.h"
#include "tool.h"

#pragma comment(lib, "ws2_32.lib")

Console::Console(){

	comHandle = INVALID_HANDLE_VALUE;

	sizecom = 4;
	curcom = totalcom = 0;
	comlist = (char **)malloc(sizeof(char *)*sizecom);
	mode = 0;

	//¿É·ÖÅäÄÚ´æµÄÆðÊ¼Î»ÖÃ
	dataSeg = 0x80001000;

	hstdout = GetStdHandle(STD_OUTPUT_HANDLE);
	WORD attr = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY | BACKGROUND_BLUE;
	SetConsoleTextAttribute(hstdout,attr);

	clearscrn();
	work();

	
}

void Console::clearscrn()
{	
	int size;
	LPDWORD lpNumber = new DWORD;
	scrn.X = SCRN_X;
	scrn.Y = SCRN_Y;
	SetConsoleScreenBufferSize(hstdout,scrn);
	GetConsoleScreenBufferInfo(hstdout,&sbinf);
	size = SCRN_X*SCRN_Y;
	scrn.X = scrn.Y = 0;
	FillConsoleOutputAttribute(hstdout,sbinf.wAttributes,size,scrn,lpNumber);
	FillConsoleOutputCharacter(hstdout,' ',size,scrn,lpNumber);
	gotoxy(0,0);
}

void Console::gotoxy(int xpos,int ypos)
{
	scrn.X = xpos;
	scrn.Y = ypos;
	SetConsoleCursorPosition(hstdout,scrn);
}

void Console::gotoxy_cur(int next)
{
	if (next == 0)
		return ;
	GetConsoleScreenBufferInfo(hstdout,&sbinf);
	int pos = sbinf.dwCursorPosition.Y*SCRN_X+sbinf.dwCursorPosition.X+next;
	if (next > 0)
	{
		if (pos > SCRN_X*SCRN_Y)
			return ;
	}
	else 
	{
		if (pos < 0)
			return ;
	}
	scrn.X = pos%SCRN_X;
	scrn.Y = pos/SCRN_X;
	SetConsoleCursorPosition(hstdout,scrn);
}

void Console::addcom(char *str)
{
	comlist[totalcom] = (char *)malloc(sizeof(char)*(strlen(str)+1));
	memcpy(comlist[totalcom++],str,strlen(str)+1);
	if (totalcom == sizecom)
	{
		sizecom <<= 1;
		char **temp = (char **)malloc(sizeof(char *)*sizecom);
		for (int i=0;i<totalcom;i++)
			temp[i] = comlist[i];
		free(comlist);
		comlist = temp;
	}
	curcom = totalcom;
}

char* Console::getcom(int next)
{
	if (totalcom == 0)
		return NULL;
	switch (next)
	{
	case 0:
		if (curcom == 0)
			return NULL;
		else return comlist[--curcom];
	case 1:
		if (curcom == totalcom-1)
			return NULL;
		else return comlist[++curcom];
	case 2:
		return comlist[totalcom-1];
	default:
		return NULL;
	}
}

void Console::parseAndRun(char buffer[], int len)
{
	cout<<endl;

	char *argv[64];
	int argc = 0;
	int in_command = 0;
	for (int i=0;buffer[i] != '\0';i++)
	{
		if (buffer[i] != ' ')
		{
			if (in_command == 0)
				argv[argc++] = &buffer[i];
			in_command = 1;
		}
		else
		{
			buffer[i] = '\0';
			in_command = 0;
		}
	}
	
	if (argc <= 2){
		if (strcmp(argv[0],"Q")==0){
			mode = -1;
		}
		else if (strcmp(argv[0],"HELP")==0){
			mode = 0;
		}
		else if (strcmp(argv[0],"COM")==0){
			if (string2num(argv[1],comNo) && comNo>0){
				mode = 1;
			}
			else{
				cout<<"Unknown command. Use ''help'' to list commands"<<endl;
			}
		}
		else if (strcmp(argv[0],"SIM")==0){
			mode = 2;
		}
		else
			cout<<"Unknown command. Use ''help'' to list commands"<<endl;
	}
	else
		cout<<"Unknown command. Use ''help'' to list commands"<<endl;
}

int Console::getInput()
{
	int len = 0, cur = 0;
	char ch;
	buffer[len] = '\0';
	while (true)
	{
		ch = getch();
		if (ch == 8)
		{
			if (cur != 0)
			{
				if (cur == len)
				{
					cur --;
					buffer[--len] = '\0';
					gotoxy_cur(-1);
					printf(" ");
					gotoxy_cur(-1);
				}
				else
				{
					memcpy(&buffer[cur-1],&buffer[cur],len-cur);
					buffer[--len] = '\0';
					printf("\b%s ",&buffer[--cur]);
					gotoxy_cur(cur-len-1);
				}
			}
		}
		else if (ch == -32)
		{
			ch = getch();
			switch (ch)
			{
			case 75: //left
				if (cur != 0)
				{
					cur --;
					gotoxy_cur(-1);
				}
				break;
			case 77: //right
				if (cur != len)
				{
					cur ++;
					gotoxy_cur(1);
				}
				break;
			case 71: //home
				gotoxy_cur(-cur);
				cur = 0;
				break;
			case 79: //end
				gotoxy_cur(len-cur);
				cur = len;
				break;
			case 83: //delete
				if (cur != len)
				{
					len--;
					memcpy(&buffer[cur],&buffer[cur+1],len-cur);
					buffer[len] = '\0';
					printf("%s ",&buffer[cur]);
					gotoxy_cur(cur-len-1);
				}
				break;
			}
		}
		else if (ch == 13)  //»Ø³µ»»ÐÐ
		{
			printf("%c",ch);
			return len;
		}
		else if (ch == 27)   //µ¥ÒýºÅ
		{
			for (int i=0;i<len;i++)
				buffer[i] = ' ';
			gotoxy_cur(-cur);
			printf("%s",buffer);
			gotoxy_cur(-len);
			cur = len = 0;
			buffer[len] = '\0';
		}
		else
		{
			if (ch <= 126 && ch >= 32)
			{
				if(ch>='a' && ch<='z')
					ch+='A'-'a';
				if (cur == len)
				{
					if (len != LimitConsoleBuffer)
					{
						cur ++;
						buffer[len++] = ch;
						buffer[len] = '\0';
						printf("%c",ch);
					}
				}
				else
				{
					if (len == LimitConsoleBuffer)
					{
						memcpy(&buffer[cur+1],&buffer[cur],len-cur-1);
						buffer[cur] = ch;
						printf("%s",&buffer[cur++]);
						gotoxy_cur(cur-len);
					}
					else
					{
						memcpy(&buffer[cur+1],&buffer[cur],len-cur);
						buffer[++len] = '\0';
						buffer[cur] = ch;
						printf("%s",&buffer[cur++]);
						gotoxy_cur(cur-len);
					}
				}
			}
		}
	}
}

void Console::work(){
	while (true)
	{
		printf(">>");
		mode = -2;
		while (mode == -2)
		{
			int len = getInput();
			parseAndRun(buffer,len);
			if (mode == -2)
				printf("\n>>");
		}
		switch (mode)
		{
			case -1:
				exit(0);
			case 0:
				runHelp();
				break;
			case 1:
				workCom();
				break;
			case 2:
				workSim();
				break;
		}
	}
}

void Console::workSim(){
	WSADATA wsaData;
	int errcode=WSAStartup(0x101,&wsaData);
	if(errcode != 0)
	{
		printf("Error ...\n");
		return ;
	}	
	sockaddr_in server;
	server.sin_family=AF_INET; //Address family
	server.sin_port=htons(8000);
	server.sin_addr.s_addr=inet_addr("127.0.0.1");
	client = socket(AF_INET,SOCK_STREAM,0);
	if(client == INVALID_SOCKET)
	{
		printf("Failed to create socket.\n");
		return ;
	}

	if(connect(client,(sockaddr*)&server,sizeof(server))!=0)
	{
		printf("Failed to bind.\n");
		return ;
	}

	int len = recv(client,buffer,LimitConsoleBuffer,0);

	if (len == 0)
	{
		printf("     Can not connect with Simulator...\n");
		closesocket(client);
		WSACleanup();
		return ;
	}
	if (len != 0)
	{
		buffer[len] = '\0';
		printf("   %s",buffer);
	}
	char ch = 'o';
	send(client,&ch,1,0);

	/*unsigned long ul = 1;	//·Ç×èÈû
	unsigned long ul = 0; //×èÈû
	ioctlsocket(client,FIONBIO,(unsigned long *)&ul);*/

	int flag=0; //±êÖ¾ÊÇ·ñÊÇ¸Õ½øÈëkernekl
	while (true)
	{		
		int k=4;
		while(k>0&&flag==0){    //print ok from kernel
			switch(recvChar(ch))
			{
				case 0:
					printf("\n     Server lost...\n");
					goto break_while;
				case -1:					
					break;
				default:
					printf("%c",ch);
					k--;
					break;
			}
		}	

		/*if(recv(client,&ch,1,0)==0)
		{
			printf("\n     Server lost...\n");
					goto break_while;		
		}*/

		cout<<">> ";
		int order_len = getInput();  //ÊäÈëÃüÁî
		int ret;
		cout<<endl;
		if((ret = kernelRun(buffer,order_len))!=0) //µ÷ÓÃkernel
			outputErrorMsg(ret);
		cout<<endl;
		flag=1;
	}
break_while:
	closesocket(client);
	WSACleanup();
	return ;
}

void Console::workCom(){
	char comName[] = "COM0";
	comName[3] = '0'+comNo;
	DCB dcb;
	comHandle = CreateFileA(comName,GENERIC_READ|GENERIC_WRITE,0,NULL,OPEN_EXISTING,0,NULL);
	if (comHandle == INVALID_HANDLE_VALUE)
	{
		printf("\n   Can not open %s\n",comName);
		return ;
	}
	GetCommState(comHandle,&dcb);
	dcb.BaudRate = 115200;
	dcb.ByteSize = 8;
	dcb.StopBits = ONESTOPBIT;
	//SetCommState(comHandle,&dcb);
	dcb.ByteSize = 8;
	dcb.Parity = NOPARITY;
	dcb.fBinary = TRUE;
	dcb.fParity = TRUE;
	SetCommState(comHandle,&dcb);
	unsigned char ch;
	DWORD size;
	printf("\n   Ok..  Connected with com...\n");

	int flag=0; //±êÖ¾ÊÇ·ñÊÇ¸Õ½øÈëkernel
	while (true)
	{		
		if (comHandle == INVALID_HANDLE_VALUE)
		{
			printf("  COM lost...\n");
			goto break_loop;
		}
		int k=4;
		
		while(k>0&&flag==0){    //print ok from kernel
			ReadFile(comHandle,&ch,1,&size,NULL);
			if(size==1)
			{			
				printf("%c",ch);
				k--;					
			}	
		}		

		cout<<"  >> ";
		int order_len = getInput();  //ÊäÈëÃüÁî
		cout<<endl;
		int ret;
		if ((ret = kernelRun(buffer,order_len))!=0){  //µ÷ÓÃkernel
			outputErrorMsg(ret); 
			break;
		}
		cout<<endl;
		flag=1;
	}
break_loop:	
	return ;
}

int Console::kernelRun(char [],int order_len)
{
	char *argv[64];
	int in_command = 0;
	int argc = 0;

	buffer[order_len]='\0';
	for (int i=0;buffer[i] != '\0';i++)
	{
		if (buffer[i] != ' ')
		{
			if (in_command == 0)
				argv[argc++] = &buffer[i];
			in_command = 1;
		}
		else
		{
			buffer[i] = '\0';			
			in_command = 0;
		}
	}

	if (argc==0) return ConsoleCommandError;
	if (strcmp(argv[0],"R")==0)
		return runR();
	if (strcmp(argv[0],"D")==0)
		return runD(argc,argv);
	if (strcmp(argv[0],"A")==0)
		return runA(argc,argv);
	if (strcmp(argv[0],"U")==0)
		return runU(argc,argv);
	if (strcmp(argv[0],"G")==0)
		return runG(argc,argv);
	if (strcmp(argv[0],"Q")==0)
		exit(0);
	if (strcmp(argv[0],"ADDTLB")==0)
		return runAddTLB(argc,argv);
	if (strcmp(argv[0],"DELTLB")==0)
		return runDelTLB(argc,argv);
	if (strcmp(argv[0],"VIEWTLB")==0)
		return runViewTLB(argc,argv);
	if (strcmp(argv[0],"LOAD")==0)
		return runLoadFile(argc,argv);
	return 0;
}

int Console::runR()
{
	int count = 0; 
	word reg;
 	char ch = 0x52;
	sendChar(ch);	       //·¢ËÍÃüÁîR
	while(count<21){       //½ÓÊÕt0-t9
		switch(recvWord(reg))
		{
			case 0:			
				return ServerLostError;
			case 1:
				if (count<10)
					cout<<"$t"<<count<<":      \t";
				else{
					if (count==10) cout<<"$SR:      \t";
					if (count==11) cout<<"$EPC:     \t";
					if (count==12) cout<<"$Cause:   \t";
					if (count==13) cout<<"$BadVAddr:\t";
					if (count==14) cout<<"$EntryHi: \t";
					if (count==15) cout<<"$EntryLo0:\t";
					if (count==16) cout<<"$EntryLo1:\t";
					if (count==17) cout<<"$Index:   \t";
					if (count==18) cout<<"$Ebase:   \t";
					if (count==19) cout<<"$Count:   \t";
					if (count==20) cout<<"$Compare: \t";
				}
				coutHexNum(reg);
				if (count%2==1)
					cout<<endl;
				else
					cout<<"\t";
				break;
			default:
				return RecvError;
		}						
		count++;
	}

	return 0;
}

int Console::runD(int argc, char* argv[64])
{
	int num = 10;
	word addr,data;
	if (argc==2){
		// if (!string2addr(argv[1],addr) || !controller.mem.visitable(addr))
		if (!string2addr(argv[1],addr))
			// nimabi
			return InvalidMemAddress;
	}else if(argc==3){
		// if (!string2addr(argv[1],addr) || !controller.mem.visitable(addr))
		if (!string2addr(argv[1],addr))
			// fuck
			return InvalidMemAddress;
		if (!string2num(argv[2],num) || num<=0)
			return ConsoleCommandError;
	}
	else{
		return ConsoleCommandError;
	}
	char ch = 0x44;
	if (sendChar(ch)!=1) return SendError;	        //·¢ËÍÃüÁîD
	if (sendWord(addr)!=1) return SendError;
	if (sendWord(num)!=1) return SendError;

	int count = 0;
	while(count<num){								//½ÓÊÕ·µ»ØÊý¾Ý
		switch(recvWord(data))
		{
			case 1:	
				cout<<"[";
				coutHexNum(addr);
				cout<<"]: ";
				coutHexNum(data);
				cout<<endl;
				addr = addr + 4;
				break;
			default:
				return RecvError;
		}						
		count++;
	}

	return 0;
}

int Console::runA(int argc, char* argv[64])
{
	word addr;
	if (argc>=2){
		if (!string2addr(argv[1],addr)){
			return InvalidMemAddress;
		}
	}
	else
		return ConsoleCommandError;

	while(true){
		cout<<"[";
		coutHexNum(addr);
		cout<<"] ";
		string command;
		getline(cin,command);
		word bin = controller.assemble(&command[0]);
		if (bin==0xFFFFFFFF){
			cout<<"Syntax Error! Please reenter!"<<endl;
			continue;
		}
		char ch = 0x41;
		if (sendChar(ch)!=1) return SendError;	        //·¢ËÍÃüÁîA
		if (sendWord(addr)!=1) return SendError;
		if (sendWord(bin)!=1) return SendError;
		if (recvChar(ch)!=1 || ch!=0) return RecvError;
		//coutHexNum(addr);
		//cout<<endl;
		addr += 4;
		if (bin==0x03E00008) break;
	}
	// append a nop
	word bin = controller.assemble("nop");
	char ch = 0x41;
	if (sendChar(ch)!=1) return SendError;
	if (sendWord(addr)!=1) return SendError;
	if (sendWord(bin)!=1) return SendError;
	if (recvChar(ch)!=1 || ch!=0) return RecvError;
	return 0;

}

int Console::runU(int argc, char* argv[64])
{
	int num = 10;
	word addr,data;
	if (argc==2){
		if (!string2addr(argv[1],addr))
			return InvalidMemAddress;
	}else if(argc==3){
		if (!string2addr(argv[1],addr))
			return InvalidMemAddress;
		if (!string2num(argv[2],num) || num<=0)
			return ConsoleCommandError;
	}
	else{
		return ConsoleCommandError;
	}
	char ch = 0x55;
	if (sendChar(ch)!=1) return SendError;	        //·¢ËÍÃüÁîU
	if (sendWord(addr)!=1) return SendError;
	if (sendWord(num)!=1) return SendError;

	int count = 0;
	while(count<num){								//½ÓÊÕ·µ»ØÊý¾Ý
		switch(recvWord(data))
		{
			case 1:	
				coutBinNum(data);
				cout<<" [";
				coutHexNum(addr);
				cout<<"]: "<<controller.antiAssemble(data)<<endl;
				addr = addr + 4;
				break;
			default:
				return RecvError;
		}						
		count++;
	}
	return 0;

}

int Console::runG(int argc, char* argv[64]){
	word addr;
	if (argc>=2){
		if (!string2addr(argv[1],addr)){
			return InvalidMemAddress;
		}
	}
	else
		return ConsoleCommandError;
	char ch = 0x47;
	if (sendChar(ch)!=1) return SendError;	        //·¢ËÍÃüÁîG
	if (sendWord(addr)!=1) return SendError;

	while (true){
		if (recvChar(ch)!=1) return RecvError;
		if (ch==4)		//end of transmission
			break;
		if (ch==7){		//interrupt
			return runInt();
		}
		if (ch==2){		//syscall
			if (recvChar(ch)!=1) return RecvError;
			if (ch==1){      //alloc
				word size;
				if (recvWord(size)!=1) return RecvError;
				if((dataSeg+size)<0x80080000){
					sendWord(dataSeg);
					dataSeg += size;
					continue;
				}
				else{
					sendWord(0x80000000);
					return 0;
				}
			}
			if (ch==2){      //read_line
				//cout<<"in read_line"<<endl;
				string line;
				if (sendWord(dataSeg)!=1) return SendError;
				getline(cin,line);
				int pos = 0;
				bool flag = true;
				word tobeSent = 0;
				while(flag){
					char cnt;
					if (pos<line.length())
						cnt = line.at(pos);
					else{
						cnt = 0;
					}
					tobeSent >>= 8;
					tobeSent = tobeSent | (cnt<<24);
					if (pos % 4==3){
						if (sendWord(tobeSent)!=1) return SendError;
						dataSeg += 4;
						tobeSent = 0;
						if (cnt==0) flag =false;
					}
					pos++;
				}
				continue;
			}
			if (ch==3){      //read_integer
				int integer;
				cin>>integer;
				if (sendWord((word)integer)!=1) return SendError;
				continue;
			}
			if (ch==4){
				//cout<<"syscall stringEqual"<<endl;
				continue;
			}
			if (ch==5){    //printInt
				//cout<<"syscall pritnInt"<<endl;
				word data;
				if (recvWord(data)!=1) return RecvError;
				cout<<(int)data<< " ";
				continue;
			}
			if (ch==6){    //printstring
				//cout<<"syscall pritnString"<<endl;
				while(true){
					if (recvChar(ch)!=1) return RecvError;
					if (ch==0) break;
					cout<<ch;
				}
				continue;
			}
			if (ch==7){
				//cout<<"syscall pritnBool"<<endl;
				word data;
				if (recvWord(data)!=1) return RecvError;
				if (data==1)
					cout<<"true";
				else
					cout<<"false";
				continue;
			}
			if (ch==8){
				return 0;
			}
			cout<<"Undefined Syscall."<<endl;
		}
		else
			cout<<ch;
	}
	return 0;
}

int Console::runInt()
{
	word cause;
	if (recvWord(cause)!=1) return RecvError;
	word ExcCode = (cause>>2) & 0x1F; 
	switch(ExcCode){
		case 0:
			cout<<"Interrupt"<<endl;
			break;
		case 2:
			cout<<"TLB miss exception in Load Instruction"<<endl;
			break;
		case 3:
			cout<<"TLB miss exception in Store Instruction"<<endl;
			break;
		default:
			cout<<"Unknown exception"<<endl;
	}
	sendChar(4);
	int i = 0 ;
	char ch;
	for(i = 0 ; i < 4 ; i += 1){
		recvChar(ch);
		printf("%c", ch);
	}
	return 0;
}

int Console::runHelp(){
	cout<<"in help"<<endl;
	return 0;
}

int Console::runViewTLB(int argc, char *argv[]){
	for (int i=0;i<8;i++){
		cout<<i<<":\t";
		coutHexNum(controller.mem.tlbEntry[i].vpn<<13);
		cout<<" ";
		coutHexNum(controller.mem.tlbEntry[i].pfn1<<12);
		cout<<" "<<controller.mem.tlbEntry[i].v1<<" ";
		coutHexNum(controller.mem.tlbEntry[i].pfn2<<12);
		cout<<" "<<controller.mem.tlbEntry[i].v2<<endl;		
	}
	return 0;
}

int Console::runDelTLB(int argc, char *argv[]){
	if (argc!=2){
		return ConsoleCommandError;
	}
	int index;
	if (!string2num(argv[1],index) || index>7 || index<0){
		return InvalidTLBIndex;
	}
	else{
		memset(controller.mem.tlbEntry+index,0,sizeof(TLB));
		char ch = 0x45;		
		sendChar(ch);	//Send E
		ch = index;
		sendChar(ch);	//Send TLB index
	}
	return 0;
}

int Console::runAddTLB(int argc, char *argv[]){
	char ch = 0x54;		//T
	word pfn,vpn;
	if (!string2addr(argv[1],vpn) || !string2addr(argv[2],pfn)){
		return InvalidMemAddress;
	}

	if (pfn%4!=0){
		return InvalidMemAddress;
	}

	controller.mem.addTLBEntry(vpn, pfn);
	int i;
	for (i=0;i<8;i++){
		if (controller.mem.tlbEntry[i].vpn==(vpn>>13)){
			break;
		}
	}
	if (i==8){
		cout<<"Error!!!"<<endl;
		exit(0);
	}
	
	sendChar(ch);
	sendChar(i);
	sendWord(controller.mem.tlbEntry[i].vpn);

	sendWord(controller.mem.tlbEntry[i].pfn1);
	if (controller.mem.tlbEntry[i].v1) 
		sendChar(1);
	else
		sendChar(0);
	sendWord(controller.mem.tlbEntry[i].pfn2);
	if (controller.mem.tlbEntry[i].v2) 
		sendChar(1);
	else
		sendChar(0);
	return 0;
}

int Console::runLoadFile(int argc, char *argv[]){
	if (argc!=3) {
		return ConsoleCommandError;
	}
	word addr;
	// if (!string2addr(argv[2],addr) || !controller.mem.visitable(addr))
	// fuck you
	if (!string2addr(argv[2],addr))
		return InvalidMemAddress;

	ifstream fin(argv[1],ios::binary);
	if (!fin.good()){
		return OpenFileError;
	}
	word inst;
	vector<word> prog;
	fin.read((char *)(&inst),sizeof(word));
	while(!fin.eof()){
		prog.push_back(inst);
		fin.read((char *)(&inst),sizeof(word));
	}
	//if (prog.at(prog.size()-1)!=0x03E00008)
		//return NoJrRaError;
	for (unsigned int i=0;i<prog.size();i++){
		char ch = 0x41;
		if (sendChar(ch)!=1) return SendError;	        //·¢ËÍÃüÁîA
		if (sendWord(addr)!=1) return SendError;
		if (sendReverseWord(prog.at(i))!=1) return SendError;
		if (recvChar(ch)!=1 || ch != 0) return RecvError;
		addr += 4;
	}
	cout<<"complete!"<<endl;
	return 0;
}

int Console::sendChar(char c){
	if (mode==2){
		return send(client,&c,1,0);
	}
	else{
		DWORD size = 0;
		while(size==0)
			WriteFile(comHandle,&c,1,&size,NULL);
		return size;
	}
}

int Console::recvChar(char& c){
	if (mode==2){
		return recv(client,&c,1,0);
	}
	else{
		DWORD size = 0;
		while(size==0)
			ReadFile(comHandle,&c,1,&size,NULL);
		return size;
	}
}

int Console::sendWord(word data){
	for (int i=0;i<4;i++){
		char c = data & 0x000000FF;
		switch(sendChar(c)){
			case 1:
				data >>= 8;
				break;
			case 0:				
			default:
				return 0;
		}
	}
	return 1;
}

int Console::sendReverseWord(word data){
	for (int i=0;i<4;i++){
		char c = (data >> (24 - i * 8)) & 0x000000FF;
		switch(sendChar(c)){
			case 1:
				break;
			case 0:
			default:
				return 0;
		}
	}
	return 1;
}

int Console::recvWord(word& data){
	data = 0;
	for (int i=0;i<4;i++){
		char c;
		word part;
		switch(recvChar(c)){
			case 1:
				part = ((word)c) & 0xFF;
				break;
			case 0:				
			default:
				return 0;
		}
		//cout<<part<<endl;
		data += (part<<(8*i));
	}
	return 1;
}

void Console::outputErrorMsg(int errCode){
	switch(errCode){
		case ConsoleCommandError:
			cout<<"No such command. Please type ''HELP'' for command list"<<endl;
			break;
		case NoInstructionError:
			cout<<"No instruction."<<endl;
			break;
		case InvalidMemAddress:
			cout<<"Invalid memory address."<<endl;
			break;
		case InvalidTLBIndex:
			cout<<"Invalid TLB index."<<endl;
			break;
		case OpenFileError:
			cout<<"Can't open file."<<endl;
			break;
		case SocketError:
			cout<<"SocketError"<<endl;
			break;
		case ServerLostError:
			cout<<"ServerLostError"<<endl;
			break;
		case RecvError:
			cout<<"Failed to receive."<<endl;
			break;
		case SendError:
			cout<<"Failed to send."<<endl;
			break;
		case NoJrRaError:
			cout<<"Failed to load. User program must end with ''jr $ra''"<<endl;
		default:
			cout<<"Unknown Error"<<endl;
	}
}