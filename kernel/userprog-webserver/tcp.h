#ifndef _H_TCP_
#define _H_TCP_ value

#define TCP_CLOSED 1
#define TCP_SYNC_RECVED 2
#define TCP_ESTABLISHED 3
#define TCP_FIN_SENT 4

extern int tcp_src_port, tcp_dst_port;
extern int tcp_src_addr[4], tcp_dst_addr[4];
extern int tcp_state;
extern int tcp_ack, tcp_seq;

#define IP_PROTOCAL_TCP 0x06

#define TCP_SRC_PORT 0
#define TCP_DST_PORT 2
#define TCP_SEQ 4
#define TCP_ACK 8
#define TCP_DATA_OFFSET 12
#define TCP_FLAGS 13
#define TCP_WINDOW 14
#define TCP_CHECKSUM 16
#define TCP_URGEN 18

#define TCP_DATA 20
#define TCP_HDR_LEN 20

#define TCP_FLAG_CWR 0x80
#define TCP_FLAG_ECE 0x40
#define TCP_FLAG_URG 0x20
#define TCP_FLAG_ACK 0x10
#define TCP_FLAG_PSH 0x08
#define TCP_FLAG_RST 0x04
#define TCP_FLAG_SYN 0x02
#define TCP_FLAG_FIN 0x01

void tcp_handle(int length);
void tcp_send_packet(int flags, int * data, int length);

#endif
