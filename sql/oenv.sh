#/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# Version: 2
# Date: 29.09.2015

check_env() {
    which whiptail > /dev/null || return 1
}

set_ora_env() {
    ORACLE_SID=$1
    old_ORAENV_ASK=$ORAENV_ASK
    ORAENV_ASK=NO
    export ORAENV_ASK ORACLE_SID
    . oraenv > /dev/null
    ORAENV_ASK=$old_ORAENV_ASK

    SQLPLUS=$ORACLE_HOME/bin/sqlplus
    ORA_VERSION=$($SQLPLUS -V | cut -d" " -f3)

    export PS1="[\u@\h \W] (oenv) ("\$\{ORACLE_SID\}") \$ "
    echo "Starting new bash with Environment for ORACLE_SID: "$ORACLE_SID
    echo "(oenv) in bash prompt indicates a running bash from oenv.sh. Type exit for leaving."
    echo "ORACLE_HOME: "$ORACLE_HOME
    echo "Version:    "$ORA_VERSION" (sqlplus -V)"
    bash
}

check_sid() {
    # return 0 when valid oratab entry is found
    # we expect a spfile or pfile for the entry
    local sid=$1
    test -f $oracle_home/dbs/init${sid}.ora && return 0
    test -f $oracle_home/dbs/spfile${sid}.ora && return 0
    return 1
}

do_sid() {
    oratab=/etc/oratab
    whipsidlist=""

    test -f $oratab || exit 0

    for sidentry in $(cat $oratab | grep -v ^# | sort)
    do
        sid=$(echo $sidentry | cut -d":" -f1)
        oracle_home=$(echo $sidentry | cut -d":" -f2)
        UNIX95=true ps -ef | awk '{print $NF}' | grep -E '^asm_pmon_'$sid'|^ora_pmon_'$sid'|^xe_pmon_XE' > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
            state="up___"
        else
            state="down_"
        fi

        check_sid $sid $oracle_home
        if [ $? -eq 0 ] ; then
            whipsidlist=${whipsidlist}" "$sid" "$state""$oracle_home" "
        fi
    done

    OPTIONS=$(whiptail --topleft --title "ORACLE_SID selection" --menu "Choose your ORACLE_SID" 15 60 4 $whipsidlist 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ $exitstatus = 0 ]; then
        set_ora_env $OPTIONS
    else
        echo "You chose cancel."
    fi
}

check_env
do_sid
