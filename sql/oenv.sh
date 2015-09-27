#/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# Version: 1
# Date: 27.09.2015

check_env() {
    which whiptail > /dev/null || (echo "missing whiptail in PATH")    
}

set_ora_env() {
    ORACLE_SID=$1
    old_ORAENV_ASK=$ORAENV_ASK
    ORAENV_ASK=NO
    export ORAENV_ASK ORACLE_SID
    . oraenv > /dev/null
    ORAENV_ASK=$old_ORAENV_ASK
    export PS1="[\u@\h \W] (oenv) ("\$\{ORACLE_SID\}") \$ "
    echo "Starting new bash with Environment for ORACLE_SID: "$ORACLE_SID
    echo "Type exit for leaving the new bash"
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

    for sidentry in $(cat $oratab | grep -v ^#)
    do
        sid=$(echo $sidentry | cut -d":" -f1)
        oracle_home=$(echo $sidentry | cut -d":" -f2)
        check_sid $sid $oracle_home
        if [ $? -eq 0 ] ; then
            whipsidlist=${whipsidlist}" "$sid" "$sid" "
        fi
    done

    OPTIONS=$(whiptail --title "ORACLE_SID selection" --menu "Choose your ORACLE_SID" 15 60 4 $whipsidlist 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ $exitstatus = 0 ]; then
        set_ora_env $OPTIONS
    else
        echo "You chose cancel."
    fi
}


do_sid
