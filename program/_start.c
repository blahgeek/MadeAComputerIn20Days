/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-07
*/

#include "defs.h"
#include "ethernet.h"
#include "arp.h"
#include "ip.h"

int _start() {

    ethernet_init();

    delay_ms(50);

    writeint(ethernet_check_link());
    writeint(ethernet_check_speed());

    while(1){
    // for(int i = 0 ; i < 10000 ; i += 1) {
        // while(!ETHERNET_ISR);
        // delay_ms(1);
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
