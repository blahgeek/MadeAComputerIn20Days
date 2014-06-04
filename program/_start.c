/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-04
*/

#include "defs.h"
#include "ethernet.h"

int data[] = {
    0xffff, 0xffff, 0xffff,
    0x0000, 0x1111, 0x2222,
    0x0806,
    0x4242, 0x4242
};

int _start() {

    ethernet_powerup();
    ethernet_reset();
    ethernet_phy_reset();

    // ethernet_send(data, 9);
    writeint(ethernet_check_iomode());
    writeint(ethernet_check_link());
    writeint(ethernet_check_speed());
    writeint(ethernet_check_duplex());

    return 0;
}
