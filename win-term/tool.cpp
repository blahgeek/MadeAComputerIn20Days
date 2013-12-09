#include "tool.h"

bool string2reg(char s[],int& result){
	string GPRName[] = {"zero","at","v0","v1","a0","a1","a2","a3","t0","t1","t2","t3","t4","t5","t6","t7","s0"
						,"s1","s2","s3","s4","s5","s6","s7","t8","t9","k0","k1","gp","sp","s8","ra"};
	if (s[0]!='$' || strlen(s)<2) return false;
	bool flag = string2num(s+1,result);
	if (result>31) flag = false;
	if (!flag){
		for (int i=0;i<32;i++){
			if (strcmp(s+1,GPRName[i].c_str())==0){
				result = i;
				return true;
			}
		}
	}
	return flag;
}

bool string2signed16(char s[],int& result){
	bool flag = string2num(s,result);
	if (result>32767 || result<-32768) flag = false;
	return flag;
}

bool string2usigned16(char s[],int& result){
	bool flag = string2num(s,result);
	if (result<0 || result>65535) flag = false;
	return flag;
}

bool string2num(char s[],int& result){
	if ( strlen(s) >2 && s[0] == '0' && s[1] == 'x'){
		return string2hex(s+2,result);
	}
	else
		return string2dec(s,result);
}

bool string2dec(char s[],int& result){
	int signal = 1;
	result = 0;
	for (unsigned int i=0;i<strlen(s);i++){
		result *= 10;
		if (i==0 && s[i]=='-'){
			signal = -1;
			continue;
		}
		if (s[i]<='9' && s[i]>='0'){
			result += s[i]-'0';
		}
		else
			return false;
	}
	result *= signal;
	return true;
}

bool string2hex(char s[],int& result){
	result = 0;
	for (unsigned int i=0;i<strlen(s);i++){
		result *= 16;
		if (s[i]<='9' && s[i]>='0'){
			result += s[i] - '0';
		}
		else if (s[i]>='a' && s[i]<='f'){
				result += s[i] - 'a' + 10;
			}
			else{
				return false;
			}
	}
	return true;
}

bool string2decaddr(char s[],word& result){
	result = 0;
	for (unsigned int i=0;i<strlen(s);i++){
		result *= 10;
		if (i==0 && s[i]=='-'){
			return false;
		}
		if (s[i]<='9' && s[i]>='0'){
			result += s[i]-'0';
		}
		else
			return false;
	}
	return true;
}

bool string2hexaddr(char s[],word& result){
	result = 0;
	for (unsigned int i=0;i<strlen(s);i++){
		result *= 16;
		if (s[i]<='9' && s[i]>='0'){
			result += s[i] - '0';
		}
		else if (s[i]>='a' && s[i]<='f'){
				result += s[i] - 'a' + 10;
		}
		else if(s[i]>='A' && s[i]<='F'){
				result += s[i] - 'A' + 10;
		}
		else{
			return false;
		}
	}
	return true;
}

bool string2addr(char s[],word& result){
	if ( strlen(s) >2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X')){
		return string2hexaddr(s+2,result);
	}
	else
		return string2decaddr(s,result);
}

int signalExtend16(int s){
	if (s>=32768){
		return s | (word)4294901760;
	}
	else
		return s & 65535; 
}

int signalExtend8(int s){
	if (s>=128){
		return s | (word)4294967040;
	}
	else
		return s & 255; 
}

void coutHexNum(word num){
	char str[] = "0x00000000";
	int pos = 9;
	while(num>0){
		int r = num % 16;
		if (r<10) 
			str[pos] = '0' + r;
		else
			str[pos] = 'a' + r - 10;
		pos--;
		num = num / 16;
	}
	cout<<str;
}

void coutBinNum(word bin){
	word mask = 2147483648;
	for (int i=0;i<32;i++){
		word m = mask & bin;
		if (m>0){
			cout<<"1";
		}
		else{
			cout<<"0";
		}
		mask>>=1;
	}
}
