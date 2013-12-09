#include "memory.h"
#include "tool.h"

Memory::Memory(){
	cell = (word*) malloc(sizeof(word)*MemSize);
	init();
}

void Memory::init(){
	memset(cell,0xFFFFFFFF,sizeof(word)*MemSize);	
	memset(tlbEntry,0,sizeof(TLB)*8);
}

bool Memory::visitable(word addr){
	int flag = (addr>>29);
	word vpn;
	if (flag==4 || flag==5){
		addr = addr & 0x1FFFFFFF;
		if ((addr/4)>=MemSize || (addr % 4 !=0))
			return false;
		else
			return true;
	}
	else{
		if (searchInTLB(addr,vpn) && (vpn/4<MemSize) && (vpn%4==0))
			return true;
		else
			return false;
	}
	
}

word Memory::readWord(word addr){
	return cell[vpn2pfn(addr)/4];
}

void Memory::writeWord(word addr,word data){
	//coutHexNum(addr);
	//cout<<" "<<data<<endl;
	cell [vpn2pfn(addr)/4] = data;
}

word Memory::readByte(word addr){
	word result = cell[vpn2pfn(addr)/4];
	switch(addr % 4){
		case 0:
			break;
		case 1:
			result >>= 8;
			break;
		case 2:
			result >>= 16;
			break;
		case 3:
			result >>= 24;
			break;
	}
	result = result & 0x000000FF;
	return result;
}

void Memory::writeByte(word addr,word data){
	word target = cell[vpn2pfn(addr)/4];
	data = data & 0x000000FF;
	switch(addr % 4){
		case 0:
			target = (target & 0xFFFFFF00) | data;
			break;
		case 1:
			target = (target & 0xFFFF00FF) | (data<<8);
			break;
		case 2:
			target = (target & 0xFF00FFFF) | (data<<16);
			break;
		case 3:
			target = (target & 0x00FFFFFF) | (data<<24);
			break;
	}
	cell[addr/4] = target;
}

bool Memory::searchInTLB(word vpn, word& pfn){
	int id;
	if ((vpn>>12) % 2 ==0)
		id =0;
	else
		id =1;
	//cout<<"vpn:"<<(vpn>>13)<<endl;
	for (int i=0;i<8;i++){
		//cout<<"tlb "<<i<<" vpn:"<<tlbEntry[i].vpn<<endl;
		if (tlbEntry[i].vpn==(vpn>>13)){
			if (id==0 && tlbEntry[i].v1==1){
				pfn = (tlbEntry[i].pfn1<<12) | (vpn & 0x00000FFF); 
				return true;
			}
			if (id==1 && tlbEntry[i].v2==1){
				pfn = (tlbEntry[i].pfn2<<12) | (vpn & 0x00000FFF);
				return true;
			}
			return false;
		}
	}
	return false;
}

word Memory::vpn2pfn(word vpn){
	int flag = (vpn>>29);
	word pfn;
	if (flag==4 || flag==5){
		pfn = vpn & 0x1FFFFFFF;
	}
	else{
		searchInTLB(vpn,pfn);
	}
	return pfn;
}

void Memory::addTLBEntry(word vpn,word pfn){
	int flag = (vpn>>29);
	if (flag==4 || flag==5){
		return;
	}
	int id = (vpn >> 12) % 2;
	vpn = vpn >> 13;
	int i;
	for (i=0;i<8;i++){
		if (tlbEntry[i].vpn==vpn){
			if (id==0){
				tlbEntry[i].v1 = 1;
				tlbEntry[i].pfn1 = pfn>>12;
			}
			else{
				tlbEntry[i].v2 = 1;
				tlbEntry[i].pfn2 = pfn>>12;
			}
			break;
		}
	}
	if (i==8){
		for (i=0;i<8;i++){
			if (tlbEntry[i].v1==0 && tlbEntry[i].v2==0){
				tlbEntry[i].vpn = vpn;
				if (id==0){
					tlbEntry[i].v1 = 1;
					tlbEntry[i].pfn1 = pfn>>12;
				}
				else{
					tlbEntry[i].v2 = 1;
					tlbEntry[i].pfn2 = pfn>>12;
				}
				break;
			}
		}
	}
	if (i==8){
		cout<<"Error: TLB is fullfilled"<<endl;
	}
}