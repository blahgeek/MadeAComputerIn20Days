
# 奋战20天，造台计算机

现在仅使用ghdl仿真，暂未加入到ISE工程中。

## Memory Map

- 0x80000000 : 数码管1
- 0x80000001 : 数码管2
- 0x80000002 : LED

## How to run

- 安装ghdl和gtkwave
- make -f Registers.makefile （仿真RegistersTestbench，或者其他几个makefile)
- open Registers.vcd （波形文件）