/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "defs.h"
#include "ethernet.h"
#include "arp.h"
#include "ip.h"

int data[] = {
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
    0x08, 0x06,
    0x23, 0x42,
};

int _start() {

    ethernet_init();

    readint();

    writeint(ethernet_check_link());
    writeint(ethernet_check_speed());


    for(int i = 0 ; i < 100 ; i += 1) {
        // while(!ETHERNET_ISR);
        delay_ms(100);
        ethernet_recv();
        if(ethernet_rx_len == -1) continue;
        int type = ethernet_rx_type;
        writeint(type);
        if(type == ETHERNET_TYPE_ARP)
            arp_handle();
        if(type == ETHERNET_TYPE_IP)
            ip_handle();
    }

    return 0;
}
