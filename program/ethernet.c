/* 
* @Author: BlahGeek
* @Date:   2014-05-26
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "defs.h"
#include "ethernet.h"
#include "utils.h"

int MAC_ADDR[6] = {0x11, 0x22, 0x33, 0x44, 0x55, 0x66};
int ethernet_rx_data[2048];

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

void ethernet_init() {
    ethernet_powerup();
    ethernet_reset();
    ethernet_phy_reset();

    // set MAC address
    for(int i = 0 ; i < 6 ; i += 1)
        ethernet_write(DM9000_REG_PAR0 + i, MAC_ADDR[i]);
    // initialize hash table
    for(int i = 0 ; i < 8 ; i += 1)
        ethernet_write(DM9000_REG_MAR0 + i, 0x00);
    // accept broadcast
    ethernet_write(DM9000_REG_MAR7, 0x80);
    // enable pointer auto return function
    ethernet_write(DM9000_REG_IMR, IMR_PAR);
    // clear NSR status
    ethernet_write(DM9000_REG_NSR, NSR_WAKEST | NSR_TX2END | NSR_TX1END);
    // clear interrupt flag
    ethernet_write(DM9000_REG_ISR, 
        ISR_UDRUN | ISR_ROO | ISR_ROS | ISR_PT | ISR_PR);
    // enable interrupt (recv only)
    ethernet_write(DM9000_REG_IMR, IMR_PAR | IMR_PRI);
    // enable reciever
    ethernet_write(DM9000_REG_RCR,
        RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN);
}

int ethernet_check_iomode() {
    int val = ethernet_read(DM9000_REG_ISR) & ISR_IOMODE;
    if(val) return 8;
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
    ethernet_write(DM9000_REG_EPAR, offset | 0x40);
    ethernet_write(DM9000_REG_EPDRH, MSB(value));
    ethernet_write(DM9000_REG_EPDRL, LSB(value));

    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS | EPCR_ERPRW);
    while(ethernet_read(DM9000_REG_EPCR) & EPCR_ERRE);
    delay_us(5);
    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS);
}

int ethernet_phy_read(int offset) {
    ethernet_write(DM9000_REG_EPAR, offset | 0x40);
    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS | EPCR_ERPRR);
    while(ethernet_read(DM9000_REG_EPCR) & EPCR_ERRE);

    ethernet_write(DM9000_REG_EPCR, EPCR_EPOS);
    delay_us(5);
    return (ethernet_read(DM9000_REG_EPDRH) << 8) | 
            ethernet_read(DM9000_REG_EPDRL);
}

void ethernet_powerup() {
    ethernet_write(DM9000_REG_GPR, 0x00);
    delay_ms(100);
}

void ethernet_reset() {
    ethernet_write(DM9000_REG_NCR, NCR_RST);
    while(ethernet_read(DM9000_REG_NCR) & NCR_RST);
}

void ethernet_phy_reset() {
    ethernet_phy_write(DM9000_PHY_REG_BMCR, BMCR_RST);
    while(ethernet_phy_read(DM9000_PHY_REG_BMCR) & BMCR_RST);
}


void ethernet_send(int * data, int length) {
    // int is char
    // A dummy write
    ethernet_write(DM9000_REG_MWCMDX, 0);
    // select reg
    *(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MWCMD;
    nop(); nop();
    for(int i = 0 ; i < length ; i += 2){
        int val = data[i];
        if(i + 1 < length) val |= (data[i+1] << 8);
        *(unsigned int *)(ENET_DATA_ADDR) = val;
        nop();
    }
    // write length
    ethernet_write(DM9000_REG_TXPLH, MSB(length));
    ethernet_write(DM9000_REG_TXPLL, LSB(length));
    // clear interrupt flag
    ethernet_write(DM9000_REG_ISR, ISR_PT);
    // transfer data
    ethernet_write(DM9000_REG_TCR, TCR_TXREQ);
}

int ethernet_recv() {
    // a dummy read
    ethernet_read(DM9000_REG_MRCMDX);
    // select reg
    *(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MRCMDX1;
    nop(); nop();
    int status = LSB(*(unsigned int *)(ENET_DATA_ADDR));
    if(status != 0x01) return -1;
    else {
        *(unsigned int *)(ENET_IO_ADDR) = DM9000_REG_MRCMD;
        nop(); nop();
        status = MSB(*(unsigned int *)(ENET_DATA_ADDR));
        nop(); nop();
        int length = *(unsigned int *)(ENET_DATA_ADDR);
        nop(); nop();
        if(status & (RSR_LCS | RSR_RWTO | RSR_PLE | 
                     RSR_AE | RSR_CE | RSR_FOE))
            return -1;
        for(int i = 0 ; i < length ; i += 2) {
            int data = *(unsigned int *)(ENET_DATA_ADDR);
            ethernet_rx_data[i] = LSB(data);
            ethernet_rx_data[i+1] = MSB(data);
        }
        // clear intrrupt
        ethernet_write(DM9000_REG_ISR, ISR_PR);
        return length;
    }
}

void ethernet_fill_hdr(int * data, int * dst, int type) {
    memcpy(data + ETHERNET_DST_MAC, dst, 6);
    memcpy(data + ETHERNET_SRC_MAC, MAC_ADDR, 6);
    data[12] = MSB(type);
    data[13] = LSB(type);
}
