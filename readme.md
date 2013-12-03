
# 奋战20天，造台计算机

- MIPS32指令集（未支持浮点运算相关指令）
- 支持中断、Syscall
- 支持TLB（指令仅支持tlbwi）

## Memory Map

- SRAM物理可用地址至 0x7fffff (8M)
- Kernel在0x80000000（物理地址0x000000）
- 中断处理代码在0x80004000（物理地址0x004000）
- 用户代码一般放在物理地址0x400000以上（使用TLB）
- $sp初始化至0x807FFFFF（物理地址0x7fffff）

- UART数据地址：0xBFD003F8（TLB转化后为0x1FD003F8）
- UART控制地址：0xBFD003FC（TLB转化后为0x1FD003FC）
- 数码管0、数码管1、LED地址分别为：0xBFD00000, 0xBFD00004, 0xBFD00008

## How to simulate

- 安装ghdl和gtkwave
- make -f Registers.makefile （仿真RegistersTestbench，或者其他几个makefile)
- open Registers.vcd （波形文件）