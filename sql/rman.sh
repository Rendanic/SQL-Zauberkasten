#!/bin/bash
#
# Starts rman with 'rman target /'.
# rlwrap is used for a readline history of commands.
#
# Parameters: all values are passed to rman like:
#   rman <all parameters>
# Without parameters 'rman target /' is used.
#
# Environment: see zk_lib.sh (ZK_RLWRAP, ZK_NORLWRAP, ZK_RLWRAP_OPT)

set -u
# shellcheck source=zk_lib.sh
. "$(dirname "$(readlink -f "$0")")/zk_lib.sh"

zk_require_oracle_home rman

if [ $# -eq 0 ]; then
    set -- target /
fi

zk_run "${ORACLE_HOME}/bin/rman" "$@"
