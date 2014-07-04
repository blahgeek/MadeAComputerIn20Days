/* 
* @Author: BlahGeek
* @Date:   2014-07-01
* @Last Modified by:   BlahGeek
* @Last Modified time: 2014-07-01
*/

#include "vga.h"

void vga_write(int row, int col, char c) {
    int addr = VGA_CONSOLE_BASE | (col << 8) | row;
    *(int *)addr = c;
}

void vga_fill(char c) {
    for(int i = 0 ; i < VGA_CONSOLE_ROW ; i += 1)
        for(int j = 0 ; j < VGA_CONSOLE_COL ; j += 1)
            vga_write(i, j, c);
}

void vga_clear() {
    vga_fill(' ');
}
