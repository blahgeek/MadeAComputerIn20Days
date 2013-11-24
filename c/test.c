void main() {
    int * digitalNum0 = (int *)0x80000000;
    int * digitalNum1 = digitalNum0 + 1;
    int * led = digitalNum1 + 1;
    volatile int * uart_data = (int *)0x80000010;
    volatile int * uart_ctrl = uart_data + 1;
    int x = 0 ;
    while(1){
        * led = x;
        * digitalNum0 = *uart_ctrl;
        if((*uart_ctrl) & 0x02){
            x += 1;
            *digitalNum1 = *uart_data;
            *uart_data = 'X';
        } else {
            *digitalNum1 = 0;
        }
        // while((*uart_ctrl) & 0x02){} // can read
        // int data = *uart_data;
        // while((*uart_ctrl) & 0x01){} // can write
        // *uart_data = data + ('a' - 'A');
        // *digitalNum0 = data;
        // *digitalNum1 = data >> 4;
    }
}
