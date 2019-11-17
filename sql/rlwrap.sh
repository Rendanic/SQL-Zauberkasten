#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@googlemail.com)
#
# automatically start the correct version of rlwrap
#
# Version: 2
# Date:    17.11.2019

# shellcheck disable=SC2046
rlwrapdir=$(dirname $(basename "$0"))/../rlwrap

if [ "$(uname -i)" = 'x86_64' ] ; then
    rlwrapexe=${rlwrapdir}/rlwrap_linux_x64
fi

$rlwrapexe "$*"
