#!/bin/bash
#
# Display Data for ASM-disk with Diskstring as 1st parameter
#
if [ $# -ne 1 ]
then
    $(basename $0)" <ASM_Diskstring>"
else
    kfod disks=all asm_diskstring="$1" asmcompatibility status verbose
fi
