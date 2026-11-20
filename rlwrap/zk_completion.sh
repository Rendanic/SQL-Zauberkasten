# shellcheck shell=bash
# shellcheck disable=SC2034
#
# Tab completion for @script in sqlplus: the part of the SQL-Zauberkasten that sets up the rlwrap filter.
# This file is sourced by zk_lib.sh, not executed.
#
# The filter is only used when everything it needs is there. Otherwise rlwrap starts as before,
# without an error message:
#   - sq.sh asked for it (ZK_COMPLETE_SQL=1), rman.sh does not
#   - ZK_NOCOMPLETE is not 1
#   - python3 is installed
#   - the rlwrap that is used has its python filter library (rlwrapfilter.py)
#
# Environment variables:
#   ZK_COMPLETE_SQL  set to 1 by sq.sh
#   ZK_NOCOMPLETE    set to 1 to switch the completion off
#   INPUTRC          if you set it yourself, it is kept and the hotkey of zk_inputrc is not used

ZK_COMPLETION_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# zk_find_filterdir <rlwrap binary>
# Prints the directory with rlwrapfilter.py that belongs to this rlwrap: the library must match
# the version of rlwrap, so only the one that is installed next to it is used.
zk_find_filterdir() {
  local bin=$1 bindir dir

  bindir=$(dirname "$(readlink -f "${bin}")")
  for dir in \
    "${RLWRAP_FILTERDIR:-}" \
    "${bindir}/../share/rlwrap/filters" \
    /usr/share/rlwrap/filters \
    /usr/local/share/rlwrap/filters; do
    if [ -n "${dir}" ] && [ -f "${dir}/rlwrapfilter.py" ]; then
      (cd "${dir}" && pwd)
      return 0
    fi
  done

  # a bundled rlwrap (rlwrap/static) brings its own library
  case "${bin}" in
    "${ZK_COMPLETION_DIR}"/static/*)
      if [ -f "${ZK_COMPLETION_DIR}/static/filters/rlwrapfilter.py" ]; then
        echo "${ZK_COMPLETION_DIR}/static/filters"
        return 0
      fi
      ;;
  esac
  return 1
}

# zk_completion_setup <rlwrap binary>
# Sets the array ZK_COMPLETION_OPTS (rlwrap options) and exports RLWRAP_FILTERDIR, ZK_FILTERLIB and
# INPUTRC when the filter can be used. The array stays empty otherwise.
zk_completion_setup() {
  local bin=$1 filterdir

  ZK_COMPLETION_OPTS=()
  [ "${ZK_COMPLETE_SQL:-0}" = 1 ] || return 0
  [ "${ZK_NOCOMPLETE:-0}" != 1 ] || return 0
  command -v python3 >/dev/null 2>&1 || return 0
  filterdir=$(zk_find_filterdir "${bin}") || return 0

  # rlwrap looks for a filter in $RLWRAP_FILTERDIR, even when a full path is given: that directory
  # has to be ours. The library of the installed rlwrap is handed to the filter in ZK_FILTERLIB.
  export ZK_FILTERLIB=${filterdir}
  export RLWRAP_FILTERDIR=${ZK_COMPLETION_DIR}
  if [ -z "${INPUTRC:-}" ]; then
    export INPUTRC=${ZK_COMPLETION_DIR}/zk_inputrc
  fi
  # -c: rlwrap only asks the filter for completions in the file name mode (and then the word is the whole path)
  ZK_COMPLETION_OPTS=(-c -z zk_filter.py -e '')
}
