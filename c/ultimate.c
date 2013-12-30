/* 
* @Author: BlahGeek
* @Date:   2013-12-27
* @Last Modified by:   BlahGeek
* @Last Modified time: 2013-12-27
*/

#define MAX_NUM 256

int main() {
    int * num0 = (int *) 0xbfd00000;
    int * num1 = num0 + 1;
    int numbers[MAX_NUM]; // at most
    int i, j;
    for(i = 0 ; i < MAX_NUM ; i += 1){
        *num0 = i;
        *num1 = i >> 4;
        int x;
        // read int
        asm("li $2, 0x3\t\n"  // $2 is $v0
            "syscall\t\n"
            "move %0, $2\t\n"
            :"=r"(x)
            :
            :"$2");
        if(x == 0)
            break;
        numbers[i] = x;
    }
    int length = i;
    for(i = 0 ; i < length-1 ; i += 1){
        for(j = 0 ; j < length-1-i ; j += 1){
            if(numbers[j] > numbers[j+1]){
                int tmp = numbers[j];
                numbers[j] = numbers[j+1];
                numbers[j+1] = tmp;
            }
        }
    }
    for(i = 0 ; i < length ; i += 1){
        int x = numbers[i];
        asm("move $4, %0\t\n"  // $4 is $a0
            "li $2, 0x5\t\n"
            "syscall\t\n"
            :
            :"r"(x)
            :"$4", "$2");
    }
    return 0;
}