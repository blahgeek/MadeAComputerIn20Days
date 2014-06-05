/* 
* @Author: BlahGeek
* @Date:   2014-06-05
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "icmp.h"
#include "ip.h"
#include "ethernet.h"
#include "utils.h"

void icmp_handle(int length) {
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    if(data[ICMP_TYPE] != ICMP_TYPE_ECHO_REQUEST)
        return;
    int * buf = ethernet_tx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    buf[ICMP_TYPE] = ICMP_TYPE_ECHO_REPLY;
    buf[ICMP_CODE] = 0;
    memcpy(buf + ICMP_ID_SEQ,
           data + ICMP_ID_SEQ,
           length - 4);
    ip_make_reply(IP_PROTOCAL_ICMP, length);
    ethernet_send();
}
