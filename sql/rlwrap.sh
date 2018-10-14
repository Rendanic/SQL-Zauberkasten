#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@googlemail.com)
#
# automatically start the correct version of rlwrap
#
# Version: 1
# Date:    14.10.2018


rlwrapdir=$(dirname $(basename $0))/../rlwrap

if [ $(uname -i) = 'x86_64' ] ; then
    rlwrapexe=${rlwrapdir}/rlwrap_linux_x64
fi

$rlwrapexe $*
