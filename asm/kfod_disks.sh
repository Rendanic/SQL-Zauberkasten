#!/bin/bash
#
# Display Data for ASM-disk with Diskstring as 1st parameter
#
# Version: 1
# Date: 17.11.2019

if [ $# -ne 1 ]
then
    # shellcheck disable=SC2086
    "$(basename $0) <ASM_Diskstring>"
else
    kfod disks=all asm_diskstring="$1" asmcompatibility status verbose
fi
