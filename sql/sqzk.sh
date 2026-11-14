#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
#
# Wrapper for sq.sh. Starts sq.sh with SQLPATH set to the ./sql directory of
# the Zauberkasten.
# Thanks to Bartlomiej.Sowa@opitz-consulting.com for this great idea.

SQLPATH=$(dirname "$(readlink -f "$0")")
export SQLPATH
exec "${SQLPATH}/sq.sh" "$@"
