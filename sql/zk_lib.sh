#!/bin/bash
# shellcheck disable=SC2034
#
# Common functions for sq.sh, rman.sh and rlwrap.sh of the SQL-Zauberkasten.
# This file is sourced, not executed.
#
# Environment variables:
#   ZK_RLWRAP     full path of the rlwrap binary to use (overrides detection)
#   ZK_NORLWRAP   set to 1 to run without rlwrap (no readline history)
#   ZK_RLWRAP_OPT options for rlwrap (default: -w 200 -i)
#   ZK_NOCOMPLETE set to 1 to switch off the tab completion of @script in sq.sh
#                 (see ../rlwrap/README.md)
#   ZK_CLIENT     sqlplus | sqlcl: force the client of sq.sh (default: sqlplus
#                 from ORACLE_HOME, else SQLcl)
#   SQLCL_BIN     path of SQLcl (set by the nix-shell), else 'sql' from PATH

ZK_LIB_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
ZK_RLWRAP_DIR=$(cd "${ZK_LIB_DIR}/../rlwrap" 2>/dev/null && pwd || echo "${ZK_LIB_DIR}/../rlwrap")

# Tab completion for @script (rlwrap filter). Optional: without the file everything works as before.
if [ -r "${ZK_RLWRAP_DIR}/zk_completion.sh" ]; then
  # shellcheck source=../rlwrap/zk_completion.sh
  . "${ZK_RLWRAP_DIR}/zk_completion.sh"
fi

zk_die() {
  echo "$(basename "$0"): $*" >&2
  exit "${ZK_RC:-1}"
}

# Prints the path of an rlwrap binary that can be started.
# Order: ZK_RLWRAP, rlwrap from PATH (an installed rlwrap always wins),
#        the bundled static rlwrap of this platform (only if none is installed).
# Returns 1 if none is found.
zk_find_rlwrap() {
  local cand

  if [ -n "${ZK_RLWRAP:-}" ]; then
    [ -x "${ZK_RLWRAP}" ] || zk_die "ZK_RLWRAP is not executable: ${ZK_RLWRAP}"
    echo "${ZK_RLWRAP}"
    return 0
  fi

  if cand=$(command -v rlwrap) && [ -n "${cand}" ]; then
    echo "${cand}"
    return 0
  fi

  # No rlwrap installed: the static one in ../rlwrap/static/<uname -m>/rlwrap, if there
  # is one for this platform and it starts.
  cand=${ZK_RLWRAP_DIR}/static/$(uname -m)/rlwrap
  if [ -x "${cand}" ] && "${cand}" --version >/dev/null 2>&1; then
    echo "${cand}"
    return 0
  fi

  return 1
}

# zk_run <program> [args...]
# Runs the program below rlwrap when possible, without rlwrap otherwise.
zk_run() {
  local rlwrap_bin opts

  export EDITOR=${EDITOR:-vi}

  if [ "${ZK_NORLWRAP:-0}" != 1 ] && [ -t 0 ] && rlwrap_bin=$(zk_find_rlwrap); then
    read -r -a opts <<<"${ZK_RLWRAP_OPT:--w 200 -i}"
    ZK_COMPLETION_OPTS=()
    if type zk_completion_setup >/dev/null 2>&1; then
      zk_completion_setup "${rlwrap_bin}"
    fi
    exec "${rlwrap_bin}" "${opts[@]}" ${ZK_COMPLETION_OPTS[@]+"${ZK_COMPLETION_OPTS[@]}"} "$@"
  fi

  if [ "${ZK_NORLWRAP:-0}" != 1 ] && [ -t 0 ]; then
    echo "$(basename "$0"): no rlwrap found, starting without command history" >&2
    echo "  install rlwrap (e.g. 'dnf install rlwrap') or set ZK_RLWRAP" >&2
  fi
  exec "$@"
}

# zk_require_oracle_home <binary>
zk_require_oracle_home() {
  [ -n "${ORACLE_HOME:-}" ] || ZK_RC=1 zk_die "ORACLE_HOME is not set"
  [ -x "${ORACLE_HOME}/bin/$1" ] || ZK_RC=1 zk_die "$1 not found: ${ORACLE_HOME}/bin/$1"
}

# zk_find_sqlcl
# Prints the path of SQLcl: SQLCL_BIN, else 'sql' from PATH. Returns 1 if none.
zk_find_sqlcl() {
  local cand

  if [ -n "${SQLCL_BIN:-}" ] && [ -x "${SQLCL_BIN}" ]; then
    echo "${SQLCL_BIN}"
    return 0
  fi
  if cand=$(command -v sql) && [ -n "${cand}" ]; then
    echo "${cand}"
    return 0
  fi
  return 1
}
