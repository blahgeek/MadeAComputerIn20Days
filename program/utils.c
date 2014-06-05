/* 
* @Author: BlahGeek
* @Date:   2014-06-05
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/


#include "utils.h"
#include "defs.h"

int memcmp(int * a, int * b, int length) {
    for(int i = 0 ; i < length ; i += 1)
        if(a[i] != b[i])
            return -1;
    return 0;
}

void memcpy(int * dst, int * src, int length) {
    for(int i = 0 ; i < length ; i += 1)
        dst[i] = src[i];
}


int mem2int(int * data, int length) {
    int ret = 0;
    for(int i = 0 ; i < length ; i += 1) {
        ret <<= 8;
        ret |= LSB(data[i]);
    }
    return ret;
}

void int2mem(int * data, int length, int val) {
    for(int i = 0 ; i < length ; i += 1) {
        data[length - i - 1] = LSB(val);
        val >>= 8;
    }
}
