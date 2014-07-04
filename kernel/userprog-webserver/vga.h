#ifndef _VGA_CONSOLE_
#define _VGA_CONSOLE_ value

#define VGA_CONSOLE_BASE 0xBFD10000
#define VGA_CONSOLE_ROW 30
#define VGA_CONSOLE_COL 80

void vga_write(int row, int col, char c);
void vga_clear();
void vga_fill(char c);

#endif
