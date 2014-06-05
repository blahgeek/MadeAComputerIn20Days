#define ENET_INT_ADDR 0xBFD00014
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
void delay_us(int us);

#define nop() asm volatile ("nop")
#define LSB(x) ((x) & 0xFF)
#define MSB(x) (((x) >> 8) & 0xFF)
