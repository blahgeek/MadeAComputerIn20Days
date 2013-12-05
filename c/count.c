
void f() {
    int * num0 = (int *) 0xbfd00000;
    int * num1 = num0 + 1;
    int i,j;
    for(i = 0 ; i < 0xff ; i += 1){
        *num0 = i & 0xf;
        *num1 = (i >> 4) & 0xf;
        for(j = 0 ; j < 0x20000; j += 1){}
    }
}