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

int * MYDATA = (int *)(0x80200000);
int MYDATA_LENGTH = 6000;
int CHUNK_LEN = 1000;// chunk_len must be devided by data length

int send_pos = 0;

int tcp_src_port, tcp_dst_port;
int tcp_src_addr[4], tcp_dst_addr[4];
int tcp_ack = 0, tcp_seq = INIT_SEQ;
int tcp_state = TCP_CLOSED;

void tcp_handle(int length) {
    int * data = ethernet_rx_data + ETHERNET_HDR_LEN + IP_HDR_LEN;
    if((data[TCP_FLAGS] & TCP_FLAG_SYN)) {
        tcp_src_port = mem2int(data + TCP_SRC_PORT, 2);
        tcp_dst_port = mem2int(data + TCP_DST_PORT, 2);
        memcpy(tcp_src_addr, data - IP_HDR_LEN + IP_SRC, 4);
        memcpy(tcp_dst_addr, data - IP_HDR_LEN + IP_DST, 4);
        tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;
        tcp_seq = INIT_SEQ;
        tcp_state = TCP_SYNC_RECVED;
        send_pos = 0;
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
        tcp_seq = mem2int(data + TCP_ACK, 4);
        tcp_ack = mem2int(data + TCP_SEQ, 4) + 1;
        tcp_state = TCP_ESTABLISHED;
        return;
    }
    if(tcp_state == TCP_ESTABLISHED) {
        tcp_ack = mem2int(data + TCP_SEQ, 4) + (length - TCP_HDR_LEN);
        tcp_seq = mem2int(data + TCP_ACK, 4);
        int pos = tcp_seq - (INIT_SEQ + 1);
        if(pos == 0 && length == TCP_HDR_LEN) return;
        if(pos == MYDATA_LENGTH) {
            tcp_send_packet(TCP_FLAG_RST, 0, 0);
            tcp_state = TCP_CLOSED;
            return;
        }
        int flag = TCP_FLAG_ACK;
        if(pos == 0) flag |= TCP_FLAG_PSH;
        tcp_send_packet(flag, MYDATA + pos, CHUNK_LEN);
        // tcp_seq += 3;
        // tcp_send_packet(TCP_FLAG_RST, 0, 0);
        // tcp_state = TCP_CLOSED;
        return;
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
    packet[TCP_CHECKSUM] = 0;
    packet[TCP_CHECKSUM + 1] = 0;
    int2mem(packet + TCP_WINDOW, 2, 1000);
    memcpy(packet + TCP_DATA, data, length);
    // calc checksum
    int sum = 0;
    sum += mem2int(tcp_src_addr, 2) + mem2int(tcp_src_addr + 2, 2);
    sum += mem2int(tcp_dst_addr, 2) + mem2int(tcp_dst_addr + 2, 2);
    sum += IP_PROTOCAL_TCP;
    length += TCP_HDR_LEN;
    sum += length;
    for(int i = 0 ; i < length ; i += 2) {
        int val = (packet[i] << 8);
        if(i + 1 != length) val |= packet[i+1];
        sum += val;
    }
    sum = (sum >> 16) + (sum & 0xffff);
    sum = (sum >> 16) + (sum & 0xffff);
    sum = ~sum;
    packet[TCP_CHECKSUM] = MSB(sum);
    packet[TCP_CHECKSUM + 1] = LSB(sum);
    ip_make_reply(IP_PROTOCAL_TCP, length);
    ethernet_tx_len = ETHERNET_HDR_LEN + IP_HDR_LEN + length;
    ethernet_send();
}
