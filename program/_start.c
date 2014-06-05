/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-05
*/

#include "defs.h"
#include "ethernet.h"

int data[] = {
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
    0x08, 0x06,
    0x23, 0x42,
};

int _start() {

    ethernet_init();

    writeint(ethernet_check_link());

    readint();

    writeint(ETHERNET_ISR);
    writeint(ethernet_recv());

    return 0;
}
