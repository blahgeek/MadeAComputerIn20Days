/* 
* @Author: BlahGeek
* @Date:   2014-06-05
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "ip.h"
#include "ethernet.h"
#include "icmp.h"
#include "utils.h"
#include "defs.h"
#include "arp.h"
#include "tcp.h"

void ip_handle() {
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN;
    // not IPv4 or header is longer than 20bit
    if(data[IP_VERSION] != IP_VERSION_VAL)
        return;

    int length = (data[IP_TOTAL_LEN] << 8) | data[IP_TOTAL_LEN + 1];
    length -= 20; // ip header

    if(data[IP_PROTOCAL] == IP_PROTOCAL_ICMP)
        icmp_handle(length);
    if(data[IP_PROTOCAL] == IP_PROTOCAL_TCP)
        tcp_handle(length);
}

void ip_make_reply(int proto, int length) {
    length += 20; // ip header
    ethernet_set_tx(ethernet_rx_src, ETHERNET_TYPE_IP);
    int * data = ethernet_tx_data + ETHERNET_HDR_LEN;
    data[IP_VERSION] = IP_VERSION_VAL;
    data[IP_TOTAL_LEN] = MSB(length);
    data[IP_TOTAL_LEN + 1] = LSB(length);
    data[IP_FLAGS] = 0;
    data[IP_FLAGS + 1] = 0;
    data[IP_TTL] = 64;
    data[IP_PROTOCAL] = proto;
    memcpy(data + IP_SRC, IP_ADDR, 4);
    memcpy(data + IP_DST, 
        ethernet_rx_data + ETHERNET_HDR_LEN + IP_SRC, 4);
}
