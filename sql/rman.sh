#!/bin/bash 
#
# This script starts rman with 'rman target /'
# rlwrap is used for getting a readline history of commands!
#
# Currently we support Linux 32/64 bit
#
# Parameters: all values are passed to rman like:
# rman <all parameters>
# 
# we use 'rman target /' when no parameter is given
#

set_env()
{

	sqshcurrdir=$(dirname $0)
	rlwrapdir=${sqshcurrdir}/../rlwrap
	RMANEXEC=${ORACLE_HOME}/bin/rman

	if [ ${#} -ne 0 ]
	then
		RMANPARAM="${*}"
	else
		RMANPARAM="target /"
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
	if [ ! -x ${RMANEXEC} ]
	then
		echo "rman not found! "${RMANEXEC}
		exit 1
	fi
	
	if [ ! -x ${RLWRAPEXEC} ]
	then
		echo "rlwrap not found! "${RLWRAPEXEC}
		exit 2
	fi
}

exec_rman()
{
	${RLWRAPEXEC} ${rlwrapoptions} ${RMANEXEC} ${RMANPARAM}
}


set_env ${*}
check_env
exec_rman

