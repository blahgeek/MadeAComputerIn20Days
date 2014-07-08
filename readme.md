
# Made A Computer In 20 Days

这个项目分别为以下三门课的作业：

## 计算机组成原理 2013-2014秋

实现了支持MIPS32部分指令的五段流水CPU，不完整支持中断和TLB。文档见`docs/MIPS32流水CPU设计实验报告.pdf`。

## 微计算机技术 2013-2014春

在上述CPU的基础上增加了对DM9000A网络设备的支持，实现了非常简单的网络协议栈，能够运行一个Web服务器。文档见`docs/基于FPGA的Web Server使用说明.pdf`。代码见`git checkout Full-Stack-FPGA-Web-Server`。

## 计算机综合实验 2013-2014夏

__In Progress__

### 2014/6/30

- 支持了更多的MIPS32指令，译码模块支持的指令整理在`docs/instructions.md`
    - 支持blez等跳转指令
    - 支持sb/lbu指令：需要对流水线做改动，sb指令需要拆分为两个读写操作，暂停流水线

see commit 1af29a291cb6c7a500cd4a739c6256c29a63d627

### 2014/7/1

- 增加了VGA显示模块，可现实单色ASCII字符，经测试可工作，具体如下：
    + 内建字符发生器，使用Core Generator生成片内ROM存放字符点阵
    + 使用Core Generator生成一片“显存”区域使用

see git tag VGA-Done

### 2014/7/2

出去玩了。

### 2014/7/3

- 根据_See MIPS Run_所描述的标准对原有的TLB模块做了改动，支持Valid位
- 增加了外部中断模块，现在支持时钟中断和串口中断，经测试时钟中断可用
- 对原有中断处理机制做了修改，在数据相关的特殊情况中也能实现精确异常

see commit db563505bbceaae3890e8fb8dad93b652ad26ab6

*TODO*：

- [ ] 根据CP0相应寄存器mask中断
- [ ] 使TLB支持Dirty位

### 2014/7/4

- 整理了代码、文档和测试样例发布至Github上供老师审阅

*TODO*：

- [ ] eret/异常产生时对切换用户、内核态; KSU_USER

### 2014/7/5

- 开始移至ucore，已在QEMU上能够成功运行中断处理代码（通过时钟中断）
- 完善指令集：支持mult, mfhi, mflo, mtlo, mthi指令

see commit ed50a9d

### 2014/7/6 - 2014/7/7

出去玩了。

### 2014/7/8

- 使用来自IP Core的乘法器，通过C代码简单测试了mult和mfhi等指令可用，see commit 4a7df76e
- **已在板子上成功运行ucore/lab1，可以在每次时钟中断时通过串口输出tick-tock**
- UCORE支持CGA
- 增加了片内ROM用作Bootloader，现在不需要另外的SRAM下载的FPGA代码，直接通过Bootloader就能把ucore写入内存，方便日后调试

*TODO*：

- [ ] 使用c写在bootloader中的下载SRAM的程序比直接使用硬件代码效率低，需要改进
