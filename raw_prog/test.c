/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-05-16
*/

#define ENET_IO_ADDR 0xBFD00018
#define ENET_DATA_ADDR 0xBFD0001C
#define LED_ADDR 0x8FD00008

unsigned int ethernet_read(unsigned int addr);
void ethernet_write(unsigned int addr, unsigned int data);


int main() {

    for(int i = 0 ; i < 0x20000 ; i += 1);
    *(int *)LED_ADDR = 0x23;

    for(int i = 0 ; i < 0x20000 ; i += 1);

    unsigned int result = ethernet_read(0x29);
    *(unsigned int *)LED_ADDR = result;

    while(1);

    return 0;
}

unsigned int ethernet_read(unsigned int addr) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    for(int i = 0 ; i < 0x2000 ; i += 1);
    return *(unsigned int *)(ENET_DATA_ADDR);
}

void ethernet_write(unsigned int addr, unsigned int data) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    *(unsigned int *)(ENET_DATA_ADDR) = data;
}
