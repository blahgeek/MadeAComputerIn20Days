#ifndef _H_ICMP_
#define _H_ICMP_ value

#define IP_PROTOCAL_ICMP 0x01

#define ICMP_TYPE 0
#define ICMP_CODE 1
#define ICMP_CHECKSUM 2
#define ICMP_ID_SEQ 4
#define ICMP_ID_SEQ_LEN 4
#define ICMP_TIMESTAMP (ICMP_ID_SEQ + ICMP_ID_SEQ_LEN)
#define ICMP_TIMESTAMP_LEN 8

#define ICMP_DATA (ICMP_TIMESTAMP + ICMP_TIMESTAMP_LEN)

#define ICMP_TYPE_ECHO_REQUEST 0x08
#define ICMP_TYPE_ECHO_REPLY 0x00

void icmp_handle(int length);

#endif
