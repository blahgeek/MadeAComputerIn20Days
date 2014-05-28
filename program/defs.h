#define ENET_IO_ADDR 0xBFD00018
#define ENET_DATA_ADDR 0xBFD0001C
#define UART_CTRL 0xBFD003FC
#define UART_DATA 0xBFD003F8
#define LED_ADDR 0x8FD00008

#define uart_readable() ((*(int *)UART_CTRL) & 0x02)
#define uart_writable() ((*(int *)UART_CTRL) & 0x01)

int readint();
void writeint(int x);

void delay_ms(int ms);

#define nop() asm volatile ("nop")
