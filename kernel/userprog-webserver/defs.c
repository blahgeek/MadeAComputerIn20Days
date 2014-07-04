/* 
* @Author: BlahGeek
* @Date:   2014-05-26
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "defs.h"

int readint() {
    int x;
    asm("li $2, 0x3\t\n"  // $2 is $v0
        "syscall\t\n"
        "move %0, $2\t\n"
        :"=r"(x)
        :
        :"$2");
    return x;
}

void writeint(int x) {
    asm("move $4, %0\t\n"  // $4 is $a0
        "li $2, 0x5\t\n"
        "syscall\t\n"
        :
        :"r"(x)
        :"$4", "$2");
}


void delay_ms(int ms) {
    for(int i = 0 ; i < ms ; i += 1)
        for(int j = 0 ; j < 446 ; j += 1);
}

void delay_us(int us) {
    for(int i = 0 ; i < us ; i += 1) {
        nop();nop();nop();
        nop();nop();
    }
}
