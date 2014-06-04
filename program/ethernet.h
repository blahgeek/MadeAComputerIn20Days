#ifndef _H_ETHERNET
#define _H_ETHERNET value

unsigned int ethernet_read(unsigned int addr);
void ethernet_write(unsigned int addr, unsigned int data);

void ethernet_phy_write(int offset, int value);
int ethernet_phy_read(int offset);

void ethernet_powerup();
void ethernet_reset();
void ethernet_phy_reset();

int ethernet_check_iomode(); // return 8 or 16bit mode
int ethernet_check_link(); // return 1 if link ok
int ethernet_check_speed(); // return 10 or 100 Mbps
int ethernet_check_duplex(); // return 1 if full duplex

void ethernet_send(int * data, int length);

#endif
