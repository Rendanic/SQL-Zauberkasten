#!/bin/bash
#
# Thorsten Bruhns (Thorsten.Bruhns@opitz-consulting.de)
# Date: 13.03.2017
#
# This script is a wrapper for sq.sh.
# It starts sq.sh with SQLPATH to ./sql of Zauberkasten
# Thanks to Bartlomiej.Sowa@opitz-consulting.com for this great idea.
#
# Known issues:
# SQLPLUS is not working under Oracle XE 11.2.0.2

SQSHPATH=$(dirname $0)
SQLPATH=$(dirname `readlink -f $0`); export SQLPATH
${SQSHPATH}/sq.sh "$*"

