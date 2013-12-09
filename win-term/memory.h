#include "head.h"

struct TLB{
	word vpn;
	word pfn1;
	word pfn2;
	bool v1;
	bool v2;
	bool d1;
	bool d2;
};

class Memory{

public:
	static const int MemSize =0x100000;
	TLB tlbEntry[8];
	Memory();

	word readWord(word);
	void writeWord(word,word);
	bool visitable(word);
	word readByte(word);
	void writeByte(word,word);
	void init();
	bool searchInTLB(word,word&);
	word vpn2pfn(word);
	void addTLBEntry(word,word);
private:
	word* cell;
};