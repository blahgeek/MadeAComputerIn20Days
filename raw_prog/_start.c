/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-05-28
*/

#define ENET_IO_ADDR 0xBFD00018
#define ENET_DATA_ADDR 0xBFD0001C
#define UART_CTRL 0xBFD003FC
#define UART_DATA 0xBFD003F8
#define LED_ADDR 0x8FD00008

int _start() {

    *(int *) LED_ADDR = 0x42;

    *(unsigned int *)(ENET_IO_ADDR) = 0x29;
    int x = *(unsigned int *)(ENET_DATA_ADDR);
    *(int *) LED_ADDR = x;

    while(1);

    return 0;
}
