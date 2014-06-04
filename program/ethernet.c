/* 
* @Author: BlahGeek
* @Date:   2014-05-26
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-04
*/

#include "defs.h"
#include "ethernet.h"

unsigned int ethernet_read(unsigned int addr) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    nop();nop();nop();
    return *(unsigned int *)(ENET_DATA_ADDR);
}

void ethernet_write(unsigned int addr, unsigned int data) {
    *(unsigned int *)(ENET_IO_ADDR) = addr;
    nop();
    *(unsigned int *)(ENET_DATA_ADDR) = data;
    nop();
}

int ethernet_check_iomode() {
    int val = ethernet_read(0xfe) >> 7;
    if(val == 1) return 8;
    return 16;
}
int ethernet_check_link() {
    return (ethernet_read(0x01) & 0x40) >> 6;
}
int ethernet_check_speed() {
    int val = ethernet_read(0x01) & 0x80;
    if(val == 0) return 100;
    return 10;
}
int ethernet_check_duplex() {
    return (ethernet_read(0x00) & 0x08) >> 3;
}

void ethernet_phy_write(int offset, int value) {
    ethernet_write(0x0c, offset | 0x40);
    ethernet_write(0x0e, (value >> 8) & 0xff);
    ethernet_write(0x0d, value & 0xff);

    ethernet_write(0x0b, 0x0a);
    while(ethernet_read(0x0b) & 0x01);
    ethernet_write(0x08, 0x00);
}

int ethernet_phy_read(int offset) {
    ethernet_write(0x0c, offset | 0x40);
    ethernet_write(0x0b, 0x0c);
    while(ethernet_read(0x0b) & 0x1);
    ethernet_write(0x0b, 0);
    return (ethernet_read(0x0e) << 8) | ethernet_read(0x0d);
}

void ethernet_powerup() {
    ethernet_write(0x1f, 0x00); // set PHYPD bit[0] = 0 in GPR REG
    delay_ms(100);
}

void ethernet_reset() {
    ethernet_write(0x00, 0x01);
    while(ethernet_read(0x00) & 0x01);
}

void ethernet_phy_reset() {
    ethernet_phy_write(0, 0x8000);
    while(!(ethernet_read(0x01) & 0x40));
    ethernet_phy_write(4, 0x01e1 | 0x0400);
    ethernet_phy_write(0, 0x1200);
    while(!(ethernet_read(0x01) & 0x40));
    delay_ms(5);
}


void ethernet_send(int * data, int length) {
    *(unsigned int *)(ENET_IO_ADDR) = 0xf8;
    nop(); nop();
    for(int i = 0 ; i < length ; i += 1){
        *(unsigned int *)(ENET_DATA_ADDR) = data[i];
        nop();
    }
    length <<= 1;
    ethernet_write(0xfd, (length >> 8) & 0xff);
    ethernet_write(0xfc, length & 0xff);
    ethernet_write(0x02, 0x01);
}
