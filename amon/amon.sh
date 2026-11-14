#!/bin/bash
#
# Starts amon (19c) from the directory 19c next to this script.
# The binary is chosen by the operating system. All parameters are passed to amon.
#
# Supported: Oracle Linux, RHEL, Rocky Linux, AlmaLinux, CentOS (7, 8, 9; newer
# releases use the 9 binary) and Ubuntu (22.04; newer releases use the 22.04 binary).
#
# Environment:
#   AMON_BIN         full path of the amon binary (skips the OS detection)
#   AMON_OS_RELEASE  file instead of /etc/os-release (for tests)

set -eu
set -o pipefail

amondir="$(dirname "$(readlink -f "$0")")/19c"

die() {
  echo "$(basename "$0"): $*" >&2
  exit 1
}

# prints the name of the binary for the OS, e.g. amon_19c_ol9
amon_binary_name() {
  local release=${AMON_OS_RELEASE:-/etc/os-release}
  local id id_like version_id major

  [ "$(uname -s)" = Linux ] || die "unsupported operating system: $(uname -s)"
  [ "$(uname -m)" = x86_64 ] || die "unsupported architecture: $(uname -m)"
  [ -r "${release}" ] || die "cannot read ${release}"

  # shellcheck source=/dev/null
  id=$(. "${release}" && echo "${ID:-}")
  # shellcheck source=/dev/null
  id_like=$(. "${release}" && echo "${ID_LIKE:-}")
  # shellcheck source=/dev/null
  version_id=$(. "${release}" && echo "${VERSION_ID:-}")
  major=${version_id%%.*}

  case " ${id} ${id_like} " in
    *" ubuntu "*)
      # only 22.04 is built, newer releases use it
      echo "amon_19c_ubuntu_22.04"
      ;;
    *" ol "* | *" rhel "* | *" centos "* | *" rocky "* | *" almalinux "* | *" fedora "*)
      case "${major}" in
        7 | 8 | 9) echo "amon_19c_ol${major}" ;;
        *)
          if [ "${major}" -gt 9 ] 2>/dev/null; then
            echo "amon_19c_ol9"
          else
            die "unsupported release: ${id} ${version_id}"
          fi
          ;;
      esac
      ;;
    *)
      die "unsupported distribution: ${id:-unknown} ${version_id}"
      ;;
  esac
}

if [ -n "${AMON_BIN:-}" ]; then
  amon=${AMON_BIN}
else
  amon="${amondir}/$(amon_binary_name)"
fi
[ -x "${amon}" ] || die "amon missing or not executable: ${amon}"

# amon needs the Oracle client libraries
if [ -n "${ORACLE_HOME:-}" ]; then
  LD_LIBRARY_PATH="${ORACLE_HOME}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
  export LD_LIBRARY_PATH
fi

exec "${amon}" "$@"
