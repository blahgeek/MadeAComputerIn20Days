/* 
* @Author: BlahGeek
* @Date:   2014-05-16
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-06-03
*/

#include "defs.h"
#include "ethernet.h"

int _start() {

    ethernet_powerup();
    delay_ms(100);
    ethernet_reset();

    return 0;
}
