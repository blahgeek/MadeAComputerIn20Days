#ifndef _H_UTILS_
#define _H_UTILS_ value

int memcmp(int * a, int * b, int length);
void memcpy(int * dst, int * src, int length);

int mem2int(int * data, int length);
void int2mem(int * data, int length, int val);

#endif
