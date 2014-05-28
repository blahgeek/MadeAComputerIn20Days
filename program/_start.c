/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-05-26
*/

#include "defs.h"
#include "ethernet.h"

int _start() {

    *(unsigned int *)(ENET_IO_ADDR) = 0x29;
    int x = *(unsigned int *)(ENET_DATA_ADDR);
    *(int *) LED_ADDR = x;
    // ethernet_write(0x5, 23);
    // writeint(ethernet_read(0x5));

    return 0;
}
