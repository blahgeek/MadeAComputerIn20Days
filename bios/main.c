/* 
* @Author: BlahGeek
* @Date:   2014-07-08
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-07-08
*/

#define ENET_INT_ADDR 0xBFD00014
#define ENET_IO_ADDR 0xBFD00018
#define ENET_DATA_ADDR 0xBFD0001C
#define UART_CTRL 0xBFD003FC
#define UART_DATA 0xBFD003F8
#define LED_ADDR 0xBFD00008
#define NUMBER_ADDR 0xBFD00000

#define uart_readable() ((*(volatile int *)UART_CTRL) & 0x02)
#define uart_writable() ((*(volatile int *)UART_CTRL) & 0x01)

unsigned int read4byte();
void write4byte(unsigned int x);

int main() {

    while(1) {

        *(int *) NUMBER_ADDR = 8;
        *(int *) (NUMBER_ADDR + 4) = 4;

        while(!uart_readable());
        int code = *(int *) UART_DATA;
        if(code == 0x42) {
            *(int *) NUMBER_ADDR = 0;
            // batch write
            unsigned int * addr = (unsigned int *) read4byte();
            int i = 0, check = 0;
            for( ; i < 16 ; i += 1) {
                unsigned int value = read4byte();
                check ^= value;
                *addr = value;
                addr += 1;
            }
            write4byte(check);
        }
    }

    return 0;
}


unsigned int read4byte() {
    unsigned int ret = 0;
    int i = 0;
    for( ; i < 4 ; i += 1) {
        while(!uart_readable());
        ret <<= 8;
        ret |= (*(volatile int *) UART_DATA);
    }
    return ret;
}

void write4byte(unsigned int x) {
    int i = 0;
    for( ; i < 4 ; i += 1) {
        while(!uart_writable());
        *(volatile int *)UART_DATA = (x >> 24);
        x <<= 8;
    }
}
