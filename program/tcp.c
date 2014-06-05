/* 
* @Author: BlahGeek
* @Date:   2014-06-05
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "tcp.h"
#include "ethernet.h"
#include "ip.h"
#include "defs.h"
#include "utils.h"

#define WINDOW_SIZE 1000
#define INIT_SEQ 1001

int tcp_src_port, tcp_dst_port;
int tcp_src_addr[4], tcp_dst_addr[4];
int tcp_ack = 0, tcp_seq = INIT_SEQ;
int tcp_state = TCP_CLOSED;

void tcp_handle(int length) {
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    writeint(0x3456);
    writeint(tcp_state);
    if((data[TCP_FLAGS] & TCP_FLAG_SYN)) {
        writeint(0x5678);
        tcp_src_port = mem2int(data + TCP_SRC_PORT, 2);
        tcp_dst_port = mem2int(data + TCP_DST_PORT, 2);
        memcpy(tcp_src_addr, data - IP_HDR_LEN + IP_SRC, 4);
        memcpy(tcp_dst_addr, data - IP_HDR_LEN + IP_DST, 4);
        tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;
        tcp_seq = INIT_SEQ;
        tcp_state = TCP_SYNC_RECVED;
        tcp_send_packet(TCP_FLAG_SYN | TCP_FLAG_ACK,
                        0, 0);
        return;
    }
    // not closed, check port & addr
    if(tcp_src_port != mem2int(data + TCP_SRC_PORT, 2)
        || tcp_dst_port != mem2int(data + TCP_DST_PORT, 2)
        || memcmp(data - IP_HDR_LEN + IP_DST, tcp_dst_addr, 4) != 0
        || memcmp(data - IP_HDR_LEN + IP_SRC, tcp_src_addr, 4) != 0) {
        return;
    }
    if(tcp_state == TCP_SYNC_RECVED &&
        (data[TCP_FLAGS] & TCP_FLAG_ACK)) {
        tcp_seq = mem2int(data + TCP_ACK, 4) + 1;
        tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;
        int d[] = {0x23, 0x42};
        tcp_send_packet(0, d, 2);
        tcp_send_packet(TCP_FLAG_RST, 0, 0);
        tcp_state = TCP_CLOSED;
    }
}

void tcp_send_packet(int flags, int * data, int length) {
    int * packet = ethernet_tx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    int2mem(packet + TCP_SRC_PORT, 2, tcp_dst_port);
    int2mem(packet + TCP_DST_PORT, 2, tcp_src_port);
    int2mem(packet + TCP_SEQ, 4, tcp_seq);
    int2mem(packet + TCP_ACK, 4, tcp_ack);
    packet[TCP_DATA_OFFSET] = 0x50;
    packet[TCP_FLAGS] = flags;
    packet[TCP_URGEN] = 0;
    packet[TCP_URGEN + 1] = 0;
    int2mem(packet + TCP_WINDOW, 2, 1000);
    memcpy(packet + TCP_DATA, data, length);
    ip_make_reply(IP_PROTOCAL_TCP, length + TCP_HDR_LEN);
    ethernet_tx_len = ETHERNET_HDR_LEN + IP_HDR_LEN + TCP_HDR_LEN;
    ethernet_send();
}
