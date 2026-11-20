#!/bin/bash
# shellcheck disable=SC1090,SC1091,SC2016,SC2030,SC2031
#
# Tests of the rlwrap choice (zk_find_rlwrap in sql/zk_lib.sh) and of the filter setup
# (rlwrap/zk_completion.sh). Everything runs in a temporary copy of the layout with small
# stand-ins for rlwrap, no real rlwrap is needed.
#
#   bash rlwrap/test_zk_lib.sh

REPO=$(dirname "$(dirname "$(readlink -f "$0")")")
T=$(mktemp -d)
ARCH=$(uname -m)
pass=0
fail=0

mkdir -p "${T}/sql" "${T}/rlwrap" "${T}/bin" "${T}/emptybin" "${T}/nopy"
cp "${REPO}/sql/zk_lib.sh" "${T}/sql/"
cp "${REPO}/rlwrap/zk_completion.sh" "${REPO}/rlwrap/zk_filter.py" "${REPO}/rlwrap/zk_scriptdoc.py" \
  "${REPO}/rlwrap/zk_inputrc" "${T}/rlwrap/"
# a PATH with the tools that the scripts need, but without python3
for tool in dirname readlink uname cat sed; do
  ln -s "$(command -v "${tool}")" "${T}/nopy/${tool}"
done

# good <file>: stand-in for an rlwrap that starts; bad <file>: one that does not
good() {
  printf '#!/bin/sh\n[ "$1" = --version ] && echo "rlwrap 0.99"\n' >"$1"
  chmod 755 "$1"
}
bad() {
  printf '#!/bin/sh\nexit 1\n' >"$1"
  chmod 755 "$1"
}

check() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
    echo "ok   $1"
  else
    fail=$((fail + 1))
    echo "FAIL $1: expected [$3] got [$2]"
  fi
}

# in_env <PATH> [NAME=value ...] -- <command>: runs the command in a subshell with the zk_lib.sh loaded
find_with() {
  (
    export PATH=$1
    shift
    for assignment in "$@"; do
      export "${assignment%%=*}=${assignment#*=}"
    done
    . "${T}/sql/zk_lib.sh"
    if result=$(zk_find_rlwrap); then echo "${result#"${T}"/}"; else echo NONE; fi
  )
}

filterdir_of() {
  (
    . "${T}/sql/zk_lib.sh"
    if result=$(zk_find_filterdir "$1"); then echo "${result#"${T}"/}"; else echo NONE; fi
  )
}

setup_with() {
  (
    export PATH=$1
    shift
    for assignment in "$@"; do
      export "${assignment%%=*}=${assignment#*=}"
    done
    . "${T}/sql/zk_lib.sh"
    zk_completion_setup "${T}/inst/bin/rlwrap"
    echo "${ZK_COMPLETION_OPTS[*]-}|${INPUTRC:-}|${RLWRAP_FILTERDIR:-}|${ZK_FILTERLIB:-}" | sed "s#${T}/#T/#g"
  )
}

# --- which rlwrap: installed first, the bundled static one only when nothing is installed
STATIC=${T}/rlwrap/static/${ARCH}/rlwrap
mkdir -p "${T}/rlwrap/static/${ARCH}"
good "${T}/bin/rlwrap"
good "${STATIC}"
check "installed rlwrap wins over the static one" "$(find_with "${T}/bin:/usr/bin:/bin")" "bin/rlwrap"
check "no rlwrap installed: the static one is used" "$(find_with "${T}/emptybin:/usr/bin:/bin")" "rlwrap/static/${ARCH}/rlwrap"
bad "${STATIC}"
check "a static one that does not start is skipped" "$(find_with "${T}/emptybin:/usr/bin:/bin")" "NONE"
check "installed rlwrap wins, static one is broken" "$(find_with "${T}/bin:/usr/bin:/bin")" "bin/rlwrap"
rm -f "${STATIC}"
check "nothing installed, nothing bundled" "$(find_with "${T}/emptybin:/usr/bin:/bin")" "NONE"
good "${STATIC}"
good "${T}/own-rlwrap"
check "ZK_RLWRAP wins over everything" "$(find_with "${T}/bin:/usr/bin:/bin" ZK_RLWRAP="${T}/own-rlwrap")" "own-rlwrap"
check "ZK_RLWRAP wins when nothing is installed" "$(find_with "${T}/emptybin:/usr/bin:/bin" ZK_RLWRAP="${T}/own-rlwrap")" "own-rlwrap"

# --- the filter library of the rlwrap that is used
mkdir -p "${T}/inst/bin" "${T}/inst/share/rlwrap/filters" "${T}/nolib/bin"
good "${T}/inst/bin/rlwrap"
good "${T}/nolib/bin/rlwrap"
: >"${T}/inst/share/rlwrap/filters/rlwrapfilter.py"
check "filter library next to the installed rlwrap" "$(filterdir_of "${T}/inst/bin/rlwrap")" "inst/share/rlwrap/filters"
if [ -d /usr/share/rlwrap/filters ]; then
  echo "skip: no filter library for an rlwrap without one (there is one in /usr/share/rlwrap/filters)"
else
  check "no filter library: none" "$(filterdir_of "${T}/nolib/bin/rlwrap")" "NONE"
fi
check "RLWRAP_FILTERDIR is respected" \
  "$(
    export RLWRAP_FILTERDIR="${T}/inst/share/rlwrap/filters"
    filterdir_of "${T}/nolib/bin/rlwrap"
  )" "inst/share/rlwrap/filters"
mkdir -p "${T}/rlwrap/static/filters"
: >"${T}/rlwrap/static/filters/rlwrapfilter.py"
check "a bundled rlwrap brings its own library" "$(filterdir_of "${STATIC}")" "rlwrap/static/filters"
if [ -d /usr/share/rlwrap/filters ]; then
  echo "skip: the bundled library is not used for others (there is one in /usr/share/rlwrap/filters)"
else
  check "the bundled library is not used for others" "$(filterdir_of "${T}/nolib/bin/rlwrap")" "NONE"
fi

# --- when is the filter switched on?
P="${T}/bin:/usr/bin:/bin"
check "sq.sh switches it on" "$(setup_with "${P}" ZK_COMPLETE_SQL=1)" \
  "-c -z zk_filter.py -e |T/rlwrap/zk_inputrc|T/rlwrap|T/inst/share/rlwrap/filters"
check "rman.sh does not (ZK_COMPLETE_SQL is not set)" "$(setup_with "${P}")" "|||"
check "ZK_NOCOMPLETE=1 switches it off" "$(setup_with "${P}" ZK_COMPLETE_SQL=1 ZK_NOCOMPLETE=1)" "|||"
check "without python3 it stays off, silently" "$(setup_with "${T}/nopy" ZK_COMPLETE_SQL=1)" "|||"
check "an INPUTRC of your own is kept" \
  "$(setup_with "${P}" ZK_COMPLETE_SQL=1 INPUTRC=/my/inputrc | cut -d'|' -f2)" "/my/inputrc"

echo "passed: ${pass}, failed: ${fail}"
rm -r "${T}"
[ "${fail}" -eq 0 ]
