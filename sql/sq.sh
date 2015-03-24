#!/bin/bash 
# $Id: sq.sh 708 2013-02-17 09:20:02Z tbr $
#
# This script starts sqlplus with 'sqlplus / as sysdba'
# rlwrap is used for getting a readline history of commands!
#
# Currently we support Linux 32/64 bit
#
# Parameters: all values are passed to sqlplus like:
# sqlplus <all parameters>
# 
# we use 'sqlplus / as sysdba' when no parameter is given
#

set_env()
{

	sqshcurrdir=$(dirname $0)
	rlwrapdir=${sqshcurrdir}/../rlwrap
	SQLPLUSEXEC=${ORACLE_HOME}/bin/sqlplus

	if [ ${#} -ne 0 ]
	then
		SQLPLUSPARAM="${*}"
	else
		SQLPLUSPARAM="/ as sysdba"
	fi

        export EDITOR=${EDITOR:-vi}

	rlwrapoptions="-w 200 -i"

	OSNAME=$(uname -o)
	if [ ${OSNAME} = 'GNU/Linux' ]
	then
		# we are on linux
		OSMACHINE=$(uname -m)
		if [ ${OSMACHINE} = 'x86_64' ]
		then
			RLWRAP=rlwrap_linux_x64
		fi
		if [ ${OSMACHINE} = 'i686' ]
		then
			RLWRAP=rlwrap_linux
		fi
	fi
	RLWRAPEXEC=${rlwrapdir}/${RLWRAP}
}

check_env()
{
	if [ ! -x ${SQLPLUSEXEC} ]
	then
		echo "sqlplus not found! "${SQLPLUSEXEC}
		exit 1
	fi
	
	if [ ! -x ${RLWRAPEXEC} ]
	then
		echo "rlwrap not found! "${RLWRAPEXEC}
		exit 2
	fi
}

exec_sqlplus()
{
	${RLWRAPEXEC} ${rlwrapoptions} ${SQLPLUSEXEC} ${SQLPLUSPARAM}
}


set_env ${*}
check_env
exec_sqlplus

