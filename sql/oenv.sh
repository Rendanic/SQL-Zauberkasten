#/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# Version: 3
# Date: 14.10.2015

check_env() {
    which whiptail > /dev/null || return 1
    DIALOG=$(which dialog 2>/dev/null || which whiptail 2>/dev/null)
}

set_path() {
    which rman.sh > /dev/null || export PATH=${BASEDIR}:$PATH
    export PATH
}

set_ora_env() {
    ORACLE_SID=$1
    # we need this parameter for RAC where oratab has DB_NAME as entry
    ORACLE_SID2=${2:-$1}
    old_ORAENV_ASK=$ORAENV_ASK
    ORAENV_ASK=NO
    export ORAENV_ASK ORACLE_SID
    . oraenv > /dev/null
    ORAENV_ASK=$old_ORAENV_ASK

    SQLPLUS=$ORACLE_HOME/bin/sqlplus
    ORA_VERSION=$($SQLPLUS -V | cut -d" " -f3)

    export ORACLE_SID=$ORACLE_SID2
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
    local rac_option=${2:-0}
    test -f $oracle_home/dbs/init${sid}.ora && return 0
    test -f $oracle_home/dbs/spfile${sid}.ora && return 0

    # check for an alternative SID
    # RAC has DB_NAME in oratab
    for filename in $(basename $(ls $ORACLE_HOME/dbs/spfile${1}[1-8].ora $ORACLE_HOME/dbs/init${1}[1-8].ora 2> /dev/null) 2>/dev/null) ; do
        # extract number from init<sid><number>.ora
        sidfn=$(echo $filename | cut -d"." -f1 )
        sidnr=${sidfn:${#sidfn}-1}
        # is the calculated sid in oratab existing?
        grep "^${sid}${sidnr}:" $oratab >/dev/null 2>&1
        if [ $? -eq 0 ] ; then
            # we found an entry
            # => ignore the calculated value, otherwise a duplicated entry in menu could be created
            return 99
        fi
        return ${sidnr}
    done

    return 99
}

do_sid() {
    oratab=/etc/oratab
    whipsidlist=""

    test -f $oratab || exit 0

    # RAC-Funktion ist etwas komplizierter...
    # Ist ein RAC ueberhaupt moeglich?
    # Ueber oratab nach pfile und spfile suchen
    # orcl => initorcl1.ora / spfileorcl1.ora
    # Ist ein RAC ueberhaupt moeglich?

    # sorting is importing for RAC. orcl comes after orcl1 if that is configured in oratab
    for sidentry in $(cat $oratab | grep -v ^# | grep -v "^\-MGMTDB:" | sort -u)
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
        retcode=$?
        if [ $retcode -ne 99 ] ; then
            if [ $retcode -ne 0 ] ; then
                sid=${sid}${retcode}
            fi
            whipsidlist=${whipsidlist}" "$sid" "$state""$oracle_home" "
        fi
    done

    OPTIONS=$($DIALOG  --title "ORACLE_SID selection" --menu "Choose your ORACLE_SID" 15 60 4 $whipsidlist 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ $exitstatus = 0 ]; then
        
        # we need a way back from sid<nr> to <sid> for RAC
        # => is it a created item or a real item from oratab?
        grep "^${OPTIONS}:" $oratab >/dev/null 2>&1
        if [ $? -ne 0 ] ; then
            # find the db_name entry
            OPTIONS2=$(grep "^${OPTIONS:0:${#OPTIONS}-1}:" $oratab | cut -d":" -f1)
            set_ora_env $OPTIONS2 $OPTIONS
        else
            set_ora_env $OPTIONS
        fi

    else
        echo "You chose cancel."
    fi
}

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set_path
check_env
do_sid
