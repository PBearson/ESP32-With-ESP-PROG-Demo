target remote :3333
mon reset halt
flushregs
thb *0x4008122c
c