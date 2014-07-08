/* 
* @Author: BlahGeek
* @Date:   2014-07-08
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-07-08
*/

#define nop() asm volatile ("nop")

int readine();
void writeint(int x);

int main() {

    int a,b,c;
    while(1) {
        a = readint();
        if (a == 0) break;
        b = readint();
        c = a * b;
        writeint(c);
    }

    return 0;
}

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

