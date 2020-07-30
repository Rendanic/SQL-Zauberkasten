#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# start amon automatically with the correct version and plattform.
#
# Version: 1
# Date:    30.07.2020
#
# todo:
# - testing with 10g
# - testing on AIX, Solaris
#
#
# safety & best practise settings in bash
set -eu
set -o pipefail

# shellcheck disable=SC2086,SC2046
amonbasedir="$(dirname $(basename $0))/../amon"

get_amonminversion() {

  SQLPLUS="${ORACLE_HOME}/bin/sqlplus"
  test -x "$SQLPLUS" || (echo "sqlplus not found. Please check Oracle Environment!" ; exit 100)

  oraversion=$("$SQLPLUS" -V | grep "SQL" | cut -d" " -f3 | cut -d"." -f1-2)
  if [ "$oraversion" = "10.2" ] ; then
    # we are on 10.2!
    echo "10.2"
  else
    echo "11.2"
  fi
}

#
# MAIN
#
if [ "$(uname -o)" = "GNU/Linux" ] ; then
  # we are on Linux!

  if [ -f "/etc/redhat-release" ] ; then
    # we are on RedHat / OracleLinux!
    AMON="${amonbasedir}/$(get_amonminversion)/amon64_ol5_$(get_amonminversion)"
  else

    echo "Cannot start amon on $(uname -o). Unknown Distribution."
    exit 99

  fi
else
  echo "Cannot start amon on Linux. Unknown Distribution."
fi

test -x "$AMON" || (echo "amon missing or not executable: $AMON" ; exit 98)

"$AMON" "$@"