
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

- [x] 根据CP0相应寄存器mask中断 
- [ ] 使TLB支持Dirty位

### 2014/7/4

- 整理了代码、文档和测试样例发布至Github上供老师审阅

*TODO*：

- [ ] 执行特权指令时检查KSU_USER

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
- 中断控制器检查CP0寄存器中的IE、EXL状态位来屏蔽中断

*TODO*：

- [x] 使用c写在bootloader中的下载SRAM的程序比直接使用硬件代码效率低，需要改进。使用`-O2`优化后无法正常工作。
- [x] TLB异常时设置BadVAddr寄存器


### 2014/7/9

- 保持Timer中断信号直至Compare寄存器被更新，防止中断信号被忽略
- **UCORE: check_vmm() passed!**
- **UCORE: Console input is working!**
- 把SFS镜像文件改为大端（花了整个半天时间orz）
- **增加了“断点调试”，能通过拨码开关使CPU在某个PC值时停下来**

*TODO*:

- [ ] Kernel Panic 调不出来啊啊啊啊啊啊啊啊啊


### 2014/7/10

继续调诡异的Kernel Panic无果…初步判断是访存问题，尝试降频运行，但是降频后串口无法正常运行（因为串口模块使用了单独的时钟，为了满足115200的波特率），正在尝试解决。

- CPU降频后串口无法工作的问题解决

### 2014/7/11

周五课堂报告。

### 2014/7/12 - 2014/7/13

周末，出去玩了。

### 2013/7/14

- 学会使用ChipScope了！即将开始调试！

### 2013/7/15

- UCORE: 使用ramdisk代替flash，实现ramdisk驱动
- 成功使用了ChipScope，但是插入ChipScope代码后BUG无法稳定重现！？

### 2013/7/16

- 怀疑是TLB的实现有问题（之前为了更高速度使用了与其他模块不同的下降沿时钟触发），使用组合逻辑重新实现。见branch sync-tlb
- 依然怀疑TLB的实现有问题，写了一个永远不会返回错误的DummyTLB，见branch dummy-tlb

不过折腾了一天，问题依旧，看来与TLB无关……

### 2013/7/17

- **UCORE: 在QEMU上运行用户程序通过！**
- BUG……………………周五前再调不出来就上多周期吧……

### 2013/7/19 - 2013/7/22 调试总结

这几天（除去周末）依然在尝试解决诡异的BUG无果，现象总结如下：

1. 执行一段C程序，连续写一段内存后连续读一段内存，assert数据，出现错误
2. 在代码中增删nop指令会对出错结果造成影响（有时不出错）
3. 在硬件中插入ChipScope Core会对出错结果造成影响（有时不出错）
4. 降频至11.0592M不会对出错结果造成影响

第三条现象使得调试困难度大大增加。

根据第二条现象，尝试在每条指令后插入足够的nop，该测试程序可通过，接下来计划在ucore代码中试试。不过暂时不知道如何做…（因为ucore的编译过程比较复杂，需要研究一下如何写个脚本加nop）

虽然第四条现象显示与时钟频率似乎无关，不过根据第三条现象感觉应该还是与时钟有关的…（因为插入ChipScope Core应该只改变了Timing Constraint），尝试再降频至1M试试。

### 2013/7/23

- **UCORE: stdin可工作，在QEMU上可运行sh并正确执行ls/forktest等**

CPU降频至1M现象无变化，可以肯定与频率无关。

UCore写文件系统还无法工作。
