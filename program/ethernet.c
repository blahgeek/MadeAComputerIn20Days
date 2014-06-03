/* 
* @Author: BlahGeek
* @Date:   2014-05-26
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-03
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
}

void ethernet_reset() {
    ethernet_write(0x00, 0x01);
    while(ethernet_read(0x00) & 0x01);
}
