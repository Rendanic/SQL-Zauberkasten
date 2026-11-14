#!/bin/bash
#
# Display Data for ASM-disk with Diskstring as 1st parameter
#
if [ $# -ne 1 ]; then
  echo "Usage: $(basename "$0") <ASM_Diskstring>" >&2
  exit 1
else
  kfod disks=all asm_diskstring="$1" asmcompatibility status verbose
fi
