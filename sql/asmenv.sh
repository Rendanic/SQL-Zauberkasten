#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# Set shell environment for Grid-Infrastructure / Restart
#
# Version: 2
# Date: 17.11.2019

OCRLOC=/etc/oracle/ocr.loc
OLRLOC=/etc/oracle/olr.loc

if [ ! -f ${OCRLOC} ];then
    echo ${OCRLOC}" not found! Grid-Infrastructure / Restart installed?"
    exit 1
fi

. ${OCRLOC}
. ${OLRLOC}

# shellcheck disable=SC2154
ORACLE_HOME=${crs_home}
if [ -d "${ORACLE_HOME}" ];then

    # shellcheck disable=SC2154
    if [ "${local_only^^}" = 'TRUE' ]; then
        # Restart
        ORACLE_SID=+ASM
    else
        # Grid-Infrastructure
        # shellcheck disable=SC2046
        gi_nodeid=$("${crs_home}"/bin/olsnodes -n | grep "^"$("${crs_home}"/bin/olsnodes -l) | cut -f2)
        ORACLE_SID="+ASM${gi_nodeid}"
    fi

    export PATH=$ORACLE_HOME/bin:$PATH
    export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH}

    # shellcheck disable=SC2140
    export PS1="[\u@\h \W] (oenv) ("\$\{ORACLE_SID\}") \$ "
    export ORACLE_SID ORACLE_HOME

fi
