#ifndef _H_ETHERNET
#define _H_ETHERNET value

unsigned int ethernet_read(unsigned int addr);
void ethernet_write(unsigned int addr, unsigned int data);

void ethernet_phy_write(int offset, int value);
int ethernet_phy_read(int offset);

void ethernet_powerup();
void ethernet_reset();

#endif
