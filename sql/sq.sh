#!/bin/bash
#
# Starts sqlplus with 'sqlplus / as sysdba' ('/ as sysasm' for ASM instances).
# rlwrap is used for a readline history of commands.
#
# Parameters: all values are passed to sqlplus like:
#   sqlplus <all parameters>
# Without parameters 'sqlplus / as sysdba' is used.
#
# Without a database environment (no ORACLE_HOME or no sqlplus in it) SQLcl is
# used instead, e.g. from the nix-shell of the Zauberkasten. SQLcl cannot
# log in with operating system authentication, so without parameters it starts
# unconnected ('sql /nolog'). Connect with: connect user@//host:port/service
#
# Environment: see zk_lib.sh (ZK_CLIENT, ZK_RLWRAP, ZK_NORLWRAP, ZK_RLWRAP_OPT)

set -u
# shellcheck source=zk_lib.sh
. "$(dirname "$(readlink -f "$0")")/zk_lib.sh"

client=${ZK_CLIENT:-}
if [ -z "${client}" ]; then
  if [ -x "${ORACLE_HOME:-/nonexistent}/bin/sqlplus" ]; then
    client=sqlplus
  else
    client=sqlcl
  fi
fi

case "${client}" in
  sqlplus)
    zk_require_oracle_home sqlplus
    sqlclient=${ORACLE_HOME}/bin/sqlplus
    if [ $# -eq 0 ]; then
      sid=${ORACLE_SID:-}
      if [ "${sid:0:1}" = '+' ]; then
        set -- "/ as sysasm"
      else
        set -- "/ as sysdba"
      fi
    fi
    ;;
  sqlcl)
    sqlclient=$(zk_find_sqlcl) || zk_die \
      "neither sqlplus (ORACLE_HOME) nor SQLcl found; set ORACLE_HOME or start 'nix-shell'"
    echo "sq.sh: using SQLcl (${sqlclient}) instead of sqlplus" >&2
    if [ $# -eq 0 ]; then
      echo "sq.sh: not connected, use: connect user@//host:port/service" >&2
      set -- /nolog
    fi
    ;;
  *)
    zk_die "ZK_CLIENT must be sqlplus or sqlcl, not '${client}'"
    ;;
esac

zk_run "${sqlclient}" "$@"
