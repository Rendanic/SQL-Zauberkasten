#!/bin/bash
#
# Starts the best available rlwrap (see zk_lib.sh) with all parameters.

set -u
# shellcheck source=zk_lib.sh
. "$(dirname "$(readlink -f "$0")")/zk_lib.sh"

rlwrap_bin=$(zk_find_rlwrap) || zk_die "no rlwrap found"
exec "${rlwrap_bin}" "$@"
