
# 奋战20天，造台计算机

现在仅使用ghdl仿真，暂未加入到ISE工程中。

## Memory Map

- $sp(11101): start from 0x003f0000 
(begin with `lui $sp 0x3f`(001111 00000 11101 00000000 0011 1111, 0x3c1d003f))

- SRAM: 0x00000000 ~ 0x003fffff
- 0xBFD00000 (0x0FD): 数码管1
- 0xBFD00004 : 数码管2
- 0xBFD00008 : LED
- 0xBFD003F8 : UART
- 0xBFD003FC : UART control: 可读时第0位为1，可写时第1位为1

- 0x9000xxyy : VGA x行y列

## How to run

- 安装ghdl和gtkwave
- make -f Registers.makefile （仿真RegistersTestbench，或者其他几个makefile)
- open Registers.vcd （波形文件）