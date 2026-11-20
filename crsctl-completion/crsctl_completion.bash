# shellcheck shell=bash
#
# Version: 1.0
#
# Bash completion for Oracle crsctl (Oracle Restart / Grid Infrastructure cluster)
#
# Install:   source this file from ~/.bashrc, or copy it to /etc/bash_completion.d/crsctl
#
# How it works
#  - Commands, objects, options and enum values are parsed from the help of the
#    crsctl binary that is actually called: `crsctl help`, `crsctl <command> -h`
#    and `crsctl {status|add|modify} <object> -h`. The result is cached per binary
#    and mode (Oracle Restart / cluster) in ${XDG_CACHE_HOME:-~/.cache}/crsctl-completion/
#    and regenerated automatically when the crsctl binary is newer than the cache.
#  - crsctl accepts abbreviations (`crsctl stat res -t`), so they are resolved here too.
#  - Resource, type, server, server pool, resource group and category names, disk
#    groups, resource attributes and debug modules are read live from the clusterware
#    with crsctl (cached for CRSCTL_COMP_TTL seconds).
#  - The GI home is the home of the crsctl that is called. /etc/oratab is never used.
#
# Variables
#   CRSCTL_COMP_TTL     seconds to cache the crsctl output (default 10)
#   CRSCTL_COMP_CACHE   cache directory for the parsed help output

declare -gA _CRSCTL_OUT=() _CRSCTL_TS=()
_CRSCTL_LOADED=""
_CRSCTL_BIN=""
_crs_r=""

# ---------------------------------------------------------------------------
# Generator: parse the crsctl help into bash associative arrays
# ---------------------------------------------------------------------------

# stdin: help texts, separated by "#SRC" lines. $1 = gen|pairs, $2 = verbs,
# $3 = verbs for which the help of every object is read (mode pairs)
_crsctl_comp_awk() {
  awk -v mode="$1" -v verbs="$2" -v deep="$3" '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function q(s) { gsub(/\047/, "", s); return "\047" s "\047" }

    # split s at the top-level "|" into alt[1..n]
    function split_alts(s,   n, i, c, d, cur, inq) {
      n = 0; d = 0; cur = ""; inq = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\"") inq = !inq
        if (!inq) {
          if (c == "{" || c == "[" || c == "<") d++
          else if (c == "}" || c == "]" || c == ">") d--
          else if (c == "|" && d == 0) { alt[++n] = trim(cur); cur = ""; continue }
        }
        cur = cur c
      }
      alt[++n] = trim(cur)
      return n
    }

    # position of the bracket that closes the "{" or "[" at position p
    function match_close(s, p,   i, c, d, inq) {
      d = 0; inq = 0
      for (i = p; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "\"") { inq = !inq; continue }
        if (inq) continue
        if (c == "{" || c == "[") d++
        else if (c == "}" || c == "]") { d--; if (d == 0) return i }
      }
      return 0
    }

    function add_tok(t, v) { nt++; tt[nt] = t; tk[nt] = v }

    # "<a>=<b>[,...]" -> a=b, (trailing comma: comma separated list)
    function qname(t,   a, b, rest) {
      if (match(t, /<[^>]*>/)) {
        a = substr(t, RSTART + 1, RLENGTH - 2)
        rest = substr(t, RSTART + RLENGTH)
        if (substr(rest, 1, 1) == "=" && match(rest, /<[^>]*>/)) {
          b = substr(rest, RSTART + 1, RLENGTH - 2)
          a = a "=" b
        }
        if (index(t, ",...") > 0) a = a ","
        return a
      }
      if (index(t, "=") > 0) return "keyval"
      return "text"
    }

    function tokenize(s,   i, n, c, j, t) {
      nt = 0; n = length(s); i = 1
      while (i <= n) {
        c = substr(s, i, 1)
        if (c == " " || c == "\t") { i++; continue }
        if (substr(s, i, 6) == "[,...]") { add_tok("CLIST", ","); i += 6; continue }
        if (substr(s, i, 5) == "[...]") { add_tok("ELL", "..."); i += 5; continue }
        if (c == "\"") {
          j = index(substr(s, i + 1), "\"")
          if (j == 0) j = n - i + 1
          t = substr(s, i + 1, j - 1); i += j + 1
          add_tok("QPH", qname(t)); continue
        }
        if (c == "<") {
          j = index(substr(s, i), ">")
          if (j == 0) { i = n + 1; continue }
          add_tok("PH", substr(s, i + 1, j - 2)); i += j; continue
        }
        if (c == "-" && substr(s, i + 1, 1) ~ /[A-Za-z]/) {
          match(substr(s, i), /^-[A-Za-z][A-Za-z0-9_]*/)
          add_tok("OPT", substr(s, i, RLENGTH)); i += RLENGTH; continue
        }
        if (c ~ /[][{}|]/) { add_tok(c, c); i++; continue }
        if (c ~ /[A-Za-z0-9_]/) {
          match(substr(s, i), /^[A-Za-z0-9_]+/)
          add_tok("WORD", substr(s, i, RLENGTH)); i += RLENGTH; continue
        }
        i++
      }
    }

    # value that follows the option or keyword at token j: sets vname, venum, vskip
    function vspec(j,   k, d, n, e, ok, first, ev) {
      vname = ""; venum = ""; vskip = 0
      k = j + 1
      if (tt[k] == "PH" || tt[k] == "QPH") {
        vname = tk[k]; vskip = 1
        if (tt[k + 1] == "ELL") { vname = vname "*"; vskip = 2 }
        else if (tt[k + 1] == "CLIST") { vname = vname ","; vskip = 2 }
        return
      }
      if (tt[k] == "{") {
        d = 0; e = 0
        for (n = k; n <= nt; n++) {
          if (tt[n] == "{" || tt[n] == "[") d++
          else if (tt[n] == "}" || tt[n] == "]") { d--; if (d == 0) { e = n; break } }
        }
        if (e == 0) return
        ok = 1; ev = ""; first = k + 1
        for (n = k + 1; n < e; n++) {
          if (tt[n] == "|") continue
          if (tt[n] == "WORD" && tk[n] ~ /^[A-Za-z][A-Za-z0-9_]*$/ && (tt[n - 1] == "{" || tt[n - 1] == "|") && (tt[n + 1] == "|" || tt[n + 1] == "}"))
            ev = ev " " tk[n]
          else ok = 0
        }
        if (ok && ev != "") { venum = trim(ev); vname = "enum"; vskip = e - j; return }
        if (tt[first] == "PH") { vname = tk[first]; vskip = e - j }
        return
      }
      if (tt[k] == "WORD" && tk[k] ~ /^[a-z][a-z0-9_]+$/) { vname = tk[k]; vskip = 1 }
    }

    function reg_opt(path, o) {
      if (!((path, o) in hasopt)) { hasopt[path, o] = 1; opts[path] = opts[path] " " o }
    }
    function reg_arg(path, o, nm, en,   w, nw, i) {
      if (!((path, o) in hasarg)) { hasarg[path, o] = 1; argkeys[++na] = path SUBSEP o; arg[path, o] = nm }
      else if (arg[path, o] == "") arg[path, o] = nm
      if (en != "") {
        nw = split(en, w, " ")
        for (i = 1; i <= nw; i++)
          if (index(" " enm[path, o] " ", " " w[i] " ") == 0) enm[path, o] = trim(enm[path, o] " " w[i])
      }
    }
    # positional arguments come from the first help text that has any for this path
    function reg_pos(path, nm,   base) {
      base = nm; sub(/[*,]$/, "", base)
      if (base == "options") return
      if (!(path in possrc)) possrc[path] = src
      if (possrc[path] != src) return
      if (!((path, base) in haspos)) { haspos[path, base] = 1; pos[path] = pos[path] " " nm }
    }

    function parse_rest(path, rest,   j, t, k, suf) {
      tokenize(rest)
      for (j = 1; j <= nt; j++) {
        t = tt[j]
        if (t == "OPT") {
          reg_opt(path, tk[j])
          vspec(j)
          if (vname != "") { reg_arg(path, tk[j], vname, venum); j += vskip }
        } else if (t == "PH" || t == "QPH") {
          k = j + 1; suf = ""
          if (tt[k] == "ELL") { suf = "*"; k++ }
          else if (tt[k] == "CLIST") { suf = ","; k++ }
          reg_pos(path, tk[j] suf)
          j = k - 1
        } else if (t == "WORD" && tk[j] ~ /^[a-z][a-z0-9_]+$/) {
          vspec(j)
          if (vname != "") { reg_opt(path, tk[j]); reg_arg(path, tk[j], vname, venum); j += vskip }
        }
      }
    }

    function emit(path, rest,   pw, np, i, par, cur) {
      np = split(path, pw, " ")
      if (!(pw[1] in isverb)) return
      par = ""
      for (i = 1; i <= np; i++) {
        cur = (par == "" ? pw[i] : par " " pw[i])
        if (par != "" && !((par, pw[i]) in seenchild)) {
          seenchild[par, pw[i]] = 1
          if (child[par] == "") cpath[++ncp] = par
          child[par] = child[par] " " pw[i]
        }
        par = cur
      }
      if (!(path in known)) { known[path] = 1; paths[++npaths] = path }
      parse_rest(path, rest)
    }

    # leading literal words (also {a|b|c} and {a <x>|b}) form the command path
    function expand_one(path, rest,   c, cl, inner, n, i, ok, tail, w) {
      while (1) {
        rest = trim(rest)
        c = substr(rest, 1, 1)
        if (c == "{") {
          cl = match_close(rest, 1)
          if (cl == 0) break
          inner = substr(rest, 2, cl - 2)
          n = split_alts(inner)
          ok = (n > 0)
          for (i = 1; i <= n; i++) {
            nalt[i] = alt[i]
            if (alt[i] !~ /^[a-z][a-z0-9_]*([ \t]|$)/) ok = 0
          }
          if (!ok) break
          tail = substr(rest, cl + 1)
          for (i = 1; i <= n; i++) { qt++; qpath[qt] = path; qrest[qt] = nalt[i] " " tail }
          return
        }
        if (match(rest, /^[a-z][a-z0-9_]*([ \t]|$)/)) {
          w = substr(rest, 1, RLENGTH); gsub(/[ \t]/, "", w)
          path = path (path == "" ? "" : " ") w
          rest = substr(rest, RLENGTH + 1)
          continue
        }
        break
      }
      if (path != "") emit(path, rest)
    }

    function handle(line) {
      sub(/^[ \t]*crsctl[ \t]+/, "", line)
      qh = 1; qt = 1; qpath[1] = ""; qrest[1] = trim(line)
      while (qh <= qt) { expand_one(qpath[qh], qrest[qh]); qh++ }
    }

    BEGIN {
      nv = split(verbs, va, " ")
      for (i = 1; i <= nv; i++) { isverb[va[i]] = 1; verbs_out = verbs_out " " va[i] }
    }
    /^#SRC/ { src++; next }
    /^[ \t]+crsctl[ \t]/ { if ($0 !~ /e\.g\./) handle($0) }
    END {
      if (mode == "pairs") {
        nv = split(trim(verbs_out), va, " ")
        for (i = 1; i <= nv; i++) {
          if (index(" " deep " ", " " va[i] " ") == 0) continue
          nc = split(trim(child[va[i]]), ca, " ")
          for (j = 1; j <= nc; j++) print va[i], ca[j]
        }
        exit
      }
      print "_CRS_VERBS=" q(trim(verbs_out))
      print "declare -gA _CRS_CHILD=() _CRS_OPTS=() _CRS_ARG=() _CRS_ENUM=() _CRS_POS=()"
      for (i = 1; i <= ncp; i++) print "_CRS_CHILD[" q(cpath[i]) "]=" q(trim(child[cpath[i]]))
      for (i = 1; i <= npaths; i++) {
        p = paths[i]
        if (opts[p] != "") print "_CRS_OPTS[" q(p) "]=" q(trim(opts[p]))
        if (pos[p] != "") print "_CRS_POS[" q(p) "]=" q(trim(pos[p]))
      }
      for (i = 1; i <= na; i++) {
        split(argkeys[i], ka, SUBSEP)
        print "_CRS_ARG[" q(ka[1] "|" ka[2]) "]=" q(arg[ka[1], ka[2]])
        if ((ka[1], ka[2]) in enm) print "_CRS_ENUM[" q(ka[1] "|" ka[2]) "]=" q(enm[ka[1], ka[2]])
      }
    }'
}

_crsctl_comp_gen() {
  # $1 = path of the crsctl binary
  local crsctl=$1 tmp verbs v o f n=0 stream
  # Only these commands are asked for the help of every object: the verb level help
  # of the others is complete, and `crsctl <command> <object> -h` is not run for
  # commands that act on the stack (stop, start ...) just to read the help.
  local deep="status add modify"
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/crsctl-comp.XXXXXX") || return 1

  verbs=$("$crsctl" help 2>/dev/null | sed -n 's/^[[:space:]]*command:[[:space:]]*//p' | tr '|' ' ')
  if [[ -z $verbs ]]; then
    verbs=$("$crsctl" -h 2>/dev/null | sed -n 's/^[[:space:]]*crsctl[[:space:]]\{1,\}\([a-z][a-z]*\)[[:space:]]\{1,\}- .*/\1/p')
  fi
  if [[ -z $verbs ]]; then
    rm -rf -- "$tmp"
    return 1
  fi

  # 1) help of every command (the native binary is fast, so run a few at a time)
  for v in $verbs; do
    "$crsctl" "$v" -h >"$tmp/v_$v" 2>/dev/null &
    ((++n % 12)) || wait
  done
  wait

  # 2) help of the objects of the commands in $deep
  while read -r v o; do
    [[ -n $o ]] || continue
    "$crsctl" "$v" "$o" -h >"$tmp/o_${v}_$o" 2>/dev/null &
    ((++n % 12)) || wait
  done < <(for f in "$tmp"/v_*; do
    printf '#SRC\n'
    cat "$f"
  done | _crsctl_comp_awk pairs "$verbs" "$deep")
  wait

  # 3) objects first (more detailed), then the command level
  stream=$(
    for f in "$tmp"/o_* "$tmp"/v_*; do
      [[ -f $f ]] || continue
      printf '#SRC\n'
      cat "$f"
    done
  )
  _crsctl_comp_awk gen "$verbs" "$deep" <<<"$stream"
  rm -rf -- "$tmp"
}

# ---------------------------------------------------------------------------
# Mode, binary and cache
# ---------------------------------------------------------------------------

# "restart" (Oracle Restart), "cluster" (GI cluster) or "none"
_crsctl_comp_mode() {
  local lo
  [[ -r /etc/oracle/ocr.loc ]] || {
    echo none
    return
  }
  lo=$(sed -n 's/^local_only=//p' /etc/oracle/ocr.loc 2>/dev/null)
  if [[ ${lo^^} == TRUE ]]; then echo restart; else echo cluster; fi
}

# $1 = command word as typed. Sets _CRSCTL_BIN.
_crsctl_comp_findbin() {
  local b h
  b=$(type -P -- "$1" 2>/dev/null)
  if [[ -z $b ]]; then
    if [[ -n ${ORACLE_HOME:-} && -x $ORACLE_HOME/bin/crsctl ]]; then
      b=$ORACLE_HOME/bin/crsctl
    elif [[ -r /etc/oracle/olr.loc ]]; then
      h=$(sed -n 's/^crs_home=//p' /etc/oracle/olr.loc 2>/dev/null)
      [[ -x $h/bin/crsctl ]] && b=$h/bin/crsctl
    fi
  fi
  [[ -n $b ]] || return 1
  _CRSCTL_BIN=$b
}

_crsctl_comp_load() {
  local real sig dir file n
  _crsctl_comp_findbin "$1" || return 1
  real=$(readlink -f -- "$_CRSCTL_BIN" 2>/dev/null || printf '%s' "$_CRSCTL_BIN")
  sig=$real.$(_crsctl_comp_mode)
  [[ $_CRSCTL_LOADED == "$sig" ]] && return 0

  dir=${CRSCTL_COMP_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/crsctl-completion}
  # the help differs between Oracle Restart and a cluster => the mode is part of the name
  file=$dir/${sig//\//_}.bash
  if [[ ! -s $file || $real -nt $file ]]; then
    mkdir -p -- "$dir" 2>/dev/null || return 1
    if _crsctl_comp_gen "$_CRSCTL_BIN" >"$file.$$" 2>/dev/null && [[ -s $file.$$ ]]; then
      mv -f -- "$file.$$" "$file"
    fi
    rm -f -- "$file.$$"
  fi
  [[ -s $file ]] || return 1
  unset _CRS_VERBS _CRS_CHILD _CRS_OPTS _CRS_ARG _CRS_ENUM _CRS_POS
  # shellcheck disable=SC1090
  source "$file" || return 1

  # Not shown by the help, but used all the time: the resources of the init stack
  for n in "status resource" "start resource" "stop resource"; do
    if [[ -n ${_CRS_OPTS[$n]+x} && " ${_CRS_OPTS[$n]} " != *" -init "* ]]; then
      # shellcheck disable=SC2004  # associative array key, not arithmetic
      _CRS_OPTS[$n]+=" -init"
    fi
  done
  _CRSCTL_LOADED=$sig
}

# ---------------------------------------------------------------------------
# Live data from the clusterware
# ---------------------------------------------------------------------------

# $@ = crsctl arguments. Result in _crs_r (not on stdout: a subshell would lose the cache).
_crs_run() {
  local key="$_CRSCTL_BIN $*" now ts ttl=${CRSCTL_COMP_TTL:-10}
  now=${EPOCHSECONDS:-$(date +%s)}
  ts=${_CRSCTL_TS[$key]:-0}
  if ((now - ts < ttl)) && [[ -n ${_CRSCTL_OUT[$key]+x} ]]; then
    _crs_r=${_CRSCTL_OUT[$key]}
    return 0
  fi
  if command -v timeout >/dev/null 2>&1; then
    _crs_r=$(timeout 10 "$_CRSCTL_BIN" "$@" 2>/dev/null)
  else
    _crs_r=$("$_CRSCTL_BIN" "$@" 2>/dev/null)
  fi
  _CRSCTL_OUT[$key]=$_crs_r
  _CRSCTL_TS[$key]=$now
}

# names of `crsctl status <kind>` -> _crs_cands
_crs_objs() {
  local kind=$1 l i
  _crs_cands=()
  if [[ $kind == resource && $_crs_init == 1 ]]; then
    _crs_run status resource -init
  else
    _crs_run status "$kind"
  fi
  while IFS= read -r l; do
    case $l in
      NAME=*) _crs_cands+=("${l#NAME=}") ;;
      TYPE_NAME=*) _crs_cands+=("${l#TYPE_NAME=}") ;;
    esac
  done <<<"$_crs_r"
  # resources of a resource group are listed as name(group), only the name is valid
  for i in "${!_crs_cands[@]}"; do _crs_cands[i]=${_crs_cands[i]%%(*}; done
}

# Servers. Oracle Restart: the local host. Cluster: the cluster nodes; if the stack is
# down, the node list of the installation (crsconfig_params).
_crs_servers() {
  local l home out
  _crs_objs server
  ((${#_crs_cands[@]})) && return 0
  if [[ $(_crsctl_comp_mode) == cluster ]]; then
    home=${_CRSCTL_BIN%/bin/*}
    if [[ -x $home/bin/olsnodes ]]; then
      mapfile -t _crs_cands < <("$home/bin/olsnodes" 2>/dev/null)
    fi
    ((${#_crs_cands[@]})) && return 0
    if [[ -r $home/crs/install/crsconfig_params ]]; then
      out=$(sed -n 's/^NODE_NAME_LIST=//p' "$home/crs/install/crsconfig_params")
      IFS=, read -r -a _crs_cands <<<"$out"
    fi
  else
    l=$(hostname -s 2>/dev/null)
    [[ -n $l ]] && _crs_cands=("$l")
  fi
}

# $1 = spec of the placeholder ("+diskgroup": with a leading +)
_crs_diskgroups() {
  local plus="" l n
  [[ $1 == +* ]] && plus=+
  _crs_cands=()
  _crs_run status resource
  while IFS= read -r l; do
    n=${l#NAME=}
    n=${n%%(*}
    if [[ $l == NAME=* && $n == ora.*.dg ]]; then
      n=${n#ora.}
      _crs_cands+=("$plus${n%.dg}")
    fi
  done <<<"$_crs_r"
}

# Attribute names: of the type (-type, or a command about types), of the resources
# named on the command line, otherwise of all resources.
_crs_attrs() {
  local l key t="" i w
  local -A seen=() known=()
  local -a args=()
  _crs_cands=()
  for ((i = 0; i < ${#_crs_w[@]}; i++)); do
    [[ ${_crs_w[i]} == -type ]] && t=${_crs_w[i + 1]-}
  done
  if [[ -n $t || $_crs_node == *type* ]]; then
    if [[ -n $t ]]; then _crs_run status type "$t" -p; else _crs_run status type -p; fi
    while IFS= read -r l; do
      if [[ $l == ATTRIBUTE=* ]]; then
        key=${l#ATTRIBUTE=}
        [[ -n ${seen[$key]+x} ]] || {
          seen[$key]=1
          _crs_cands+=("$key")
        }
      fi
    done <<<"$_crs_r"
    return 0
  fi
  _crs_run status resource
  while IFS= read -r l; do
    if [[ $l == NAME=* ]]; then
      key=${l#NAME=}
      known[${key%%(*}]=1
    fi
  done <<<"$_crs_r"
  for w in "${_crs_w[@]}"; do
    [[ -n ${known[$w]+x} ]] && args+=("$w")
  done
  if ((${#args[@]})); then _crs_run status resource "${args[@]}" -p; else _crs_run status resource -p; fi
  while IFS= read -r l; do
    if [[ $l =~ ^([A-Z][A-Z0-9_]*)(@[^=]*)?= ]]; then
      key=${BASH_REMATCH[1]}
      [[ -n ${seen[$key]+x} ]] || {
        seen[$key]=1
        _crs_cands+=("$key")
      }
    fi
  done <<<"$_crs_r"
}

# debug modules of a daemon (crsctl get/set log): $1 = css|evm|crs ...
_crs_modules() {
  local l
  _crs_cands=()
  _crs_run lsmodules "$1"
  while IFS= read -r l; do
    [[ $l == *"Debug Module:"* ]] && _crs_cands+=("${l##* }")
  done <<<"$_crs_r"
}

# value of -w: attribute names, operators, TYPE/STATE/TARGET values. Sets _crs_prefix/_crs_partial.
_crs_filter() {
  local v=$_crs_cur re
  [[ -n $_crs_q ]] || return 1
  _crs_partial=${v##*[ (=<>!]}
  _crs_prefix=${v%"$_crs_partial"}
  _crs_cands=()
  re='(^|[[:space:](])TYPE[[:space:]]*(=|!=|co|coi|st|en|nc|nci|eqi)[[:space:]]*$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_objs type
    return 0
  fi
  re='(^|[[:space:](])STATE[[:space:]]*(=|!=)[[:space:]]*$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_cands=(ONLINE OFFLINE INTERMEDIATE)
    return 0
  fi
  re='(^|[[:space:](])TARGET[[:space:]]*(=|!=)[[:space:]]*$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_cands=(ONLINE OFFLINE)
    return 0
  fi
  re='^[[:space:]]*$|[(][[:space:]]*$|(^|[[:space:]])(AND|OR)[[:space:]]+$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_attrs
    _crs_cands+=(TYPE NAME STATE TARGET)
    return 0
  fi
  re='(=|!=|>|<|[[:space:]](co|coi|st|en|nc|nci|eqi))[[:space:]]*[^[:space:]()]+[[:space:]]+$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_cands=(AND OR)
    return 0
  fi
  re='(^|[[:space:](])[A-Za-z_][A-Za-z0-9_]*[[:space:]]+$'
  if [[ $_crs_prefix =~ $re ]]; then
    _crs_cands=("=" "!=" ">" "<" co coi st en nc nci eqi)
    return 0
  fi
  return 1
}

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------

# Splits the command line up to the cursor like the shell does (quotes, backslash).
# Sets _crs_w (finished words), _crs_cur (word at the cursor, without quote), _crs_q (open quote).
_crs_split() {
  local s=$1 i ch q="" word="" have=0 n=${#1}
  _crs_w=()
  for ((i = 0; i < n; i++)); do
    ch=${s:i:1}
    if [[ -n $q ]]; then
      if [[ $ch == "$q" ]]; then q=""; else word+=$ch; fi
      continue
    fi
    case $ch in
      '"' | "'")
        q=$ch
        have=1
        ;;
      "\\")
        ((i++))
        word+=${s:i:1}
        have=1
        ;;
      " " | $'\t')
        if ((have)); then
          _crs_w+=("$word")
          word=""
          have=0
        fi
        ;;
      *)
        word+=$ch
        have=1
        ;;
    esac
  done
  _crs_cur=$word
  _crs_q=$q
}

# Kind of the values of a placeholder. $1 = placeholder, $2 = command path, $3 = option ("" = positional)
_crs_kind() {
  local ph=${1,,} node=$2 opt=$3 w
  local -a nw
  _crs_kindv=""
  [[ $opt == -env ]] && return 0
  ph=${ph%%[0-9=]*}
  case $ph in
    resname | vipresname | resourcename) _crs_kindv=resource ;;
    typename) _crs_kindv="type" ;;
    rgname | resourcegroupname) _crs_kindv=resourcegroup ;;
    spname | server_pools | serverpool) _crs_kindv=serverpool ;;
    server | servername | nodename | node | node_name | host) _crs_kindv=server ;;
    categoryname) _crs_kindv=category ;;
    policy_name | policyname) _crs_kindv=policy ;;
    user_name | username | user) _crs_kindv=osuser ;;
    group_name | groupname) _crs_kindv=osgroup ;;
    +diskgroup | diskgroup | dg_name) _crs_kindv=diskgroup ;;
    attribname | attrname | attr | specification) _crs_kindv=attr ;;
    filter) _crs_kindv=filter ;;
    parameter) [[ $node == *css* ]] && _crs_kindv=cssparam ;;
    *file* | *path* | *script*) _crs_kindv="file" ;;
    name)
      read -r -a nw <<<"$node"
      for ((w = ${#nw[@]} - 1; w >= 0; w--)); do
        case ${nw[w]} in
          resource | type | resourcegroup | resourcegrouptype | serverpool | server | category)
            _crs_kindv=${nw[w]}
            break
            ;;
          policy | policyset)
            _crs_kindv=policy
            break
            ;;
        esac
      done
      ;;
  esac
  # a new object is created: no suggestion for its name
  if [[ -z $opt ]]; then
    case $node in
      "add "* | "eval add "*) _crs_kindv="" ;;
    esac
  fi
}

# Candidates for the value described by a placeholder.
# $1 = spec, $2 = option ("" = positional), $3 = command path
# Fills _crs_cands, _crs_prefix (kept in front of every candidate), _crs_partial (what is matched).
# Returns 1 = nothing to offer, 2 = COMPREPLY was filled directly (file names).
_crs_values() {
  local spec=$1 opt=$2 node=$3 comma=0 v=$_crs_cur lhs part w k last i
  _crs_cands=()
  _crs_prefix=""
  _crs_partial=$v
  [[ $spec == *'*' ]] && spec=${spec%\*}
  if [[ $spec == *, ]]; then
    comma=1
    spec=${spec%,}
  fi
  [[ $spec == specification ]] && spec=attrname=value

  # comma separated list: only the last element is completed
  if ((comma)); then
    _crs_nospace=1
    if [[ $v == *,* ]]; then
      _crs_partial=${v##*,}
      _crs_prefix=${v%"$_crs_partial"}
    fi
  fi

  if [[ $spec == enum ]]; then
    k=$node'|'$opt
    read -r -a _crs_cands <<<"${_CRS_ENUM[$k]-}"
    return 0
  fi

  last=${node##* }
  if [[ $node == "set log res" ]]; then
    spec=resname=lvl
  fi

  # NAME=VALUE (crsctl set log, -attr "A=b,C=d")
  if [[ $spec == *=* ]]; then
    lhs=${spec%%=*}
    part=$_crs_partial
    if [[ $part == *=* ]]; then
      w=${part%%=*}
      _crs_prefix=$_crs_prefix$w=
      _crs_partial=${part#*=}
      case $node in
        "set log "*) _crs_cands=(0 1 2 3 4 5) ;;
        *) return 1 ;;
      esac
      return 0
    fi
    case $node in
      "set log res") _crs_objs resource ;;
      "set log "*) _crs_modules "$last" ;;
      *)
        _crs_kind "$lhs" "$node" "$opt"
        if [[ $_crs_kindv == attr ]]; then _crs_attrs; else return 1; fi
        ;;
    esac
    for i in "${!_crs_cands[@]}"; do _crs_cands[i]=${_crs_cands[i]}=; done
    _crs_nospace=1
    return 0
  fi

  # crsctl get log <daemon> "<module>,..."
  case $node in
    "get log "* | "set log "*)
      case $last in
        mdns | gpnp | css | crf | crs | evm | gipc)
          _crs_modules "$last"
          return 0
          ;;
      esac
      ;;
  esac

  _crs_kind "$spec" "$node" "$opt"
  case $_crs_kindv in
    resource | type | resourcegroup | resourcegrouptype | serverpool | category | policy) _crs_objs "$_crs_kindv" ;;
    server) _crs_servers ;;
    diskgroup) _crs_diskgroups "$spec" ;;
    attr) _crs_attrs ;;
    osuser) mapfile -t _crs_cands < <(compgen -u) ;;
    osgroup) mapfile -t _crs_cands < <(compgen -g) ;;
    cssparam) _crs_cands=(disktimeout misscount priority reboottime) ;;
    file)
      compopt -o filenames 2>/dev/null
      mapfile -t COMPREPLY < <(compgen -f -- "$v")
      return 2
      ;;
    filter) _crs_filter || return 1 ;;
    *) return 1 ;;
  esac
  return 0
}

# appends the candidates that start with $2 to COMPREPLY, each with the open quote and $1 in front
_crs_emit() {
  local c
  for c in "${_crs_cands[@]}"; do
    [[ $c == "$2"* ]] && COMPREPLY+=("$_crs_q$1$c")
  done
}

_crsctl_complete() {
  local node="" i j k w c hit opt spec pend="" multi="" pos=0 used=" " rc children
  local -a poslist=()
  COMPREPLY=()
  _crs_w=()
  _crs_cands=()
  _crs_node=""
  _crs_init=0
  _crs_nospace=0
  _crs_prefix=""
  _crs_partial=""

  _crs_split "${COMP_LINE:0:COMP_POINT}"
  # "sudo crsctl ...": drop everything in front of crsctl
  for ((i = 0; i < ${#_crs_w[@]}; i++)); do
    [[ ${_crs_w[i]##*/} == crsctl ]] && break
  done
  ((i < ${#_crs_w[@]})) || i=0
  _crs_w=("${_crs_w[@]:i}")
  _crsctl_comp_load "${_crs_w[0]:-crsctl}" || return 0

  # command path; abbreviations are resolved like crsctl does (first match in the order of the help)
  i=1
  while ((i < ${#_crs_w[@]})); do
    w=${_crs_w[i]}
    [[ $w == -* ]] && break
    if [[ -z $node ]]; then children=$_CRS_VERBS; else children=${_CRS_CHILD[$node]-}; fi
    hit=""
    for c in $children; do
      [[ $c == "$w" ]] && {
        hit=$c
        break
      }
    done
    if [[ -z $hit ]]; then
      for c in $children; do
        [[ $c == "$w"* ]] && {
          hit=$c
          break
        }
      done
    fi
    [[ -n $hit ]] || break
    node=${node:+$node }$hit
    ((i++))
  done
  _crs_node=$node

  if [[ -z $node ]]; then
    if [[ $_crs_cur != -* ]]; then
      read -r -a _crs_cands <<<"$_CRS_VERBS"
      _crs_emit "" "$_crs_cur"
    fi
    return 0
  fi

  # arguments behind the command path: options with values, positional arguments
  for ((j = i; j < ${#_crs_w[@]}; j++)); do
    w=${_crs_w[j]}
    [[ $w == -init ]] && _crs_init=1
    if [[ -n $pend && $w != -* ]]; then
      k=$node'|'$pend
      [[ ${_CRS_ARG[$k]-} == *'*' ]] && multi=$pend
      pend=""
      continue
    fi
    if [[ -n $multi && $w != -* ]]; then
      continue
    fi
    if [[ " ${_CRS_OPTS[$node]-} " == *" $w "* ]]; then
      used+="$w "
      multi=""
      k=$node'|'$w
      pend=""
      [[ -n ${_CRS_ARG[$k]+x} ]] && pend=$w
      continue
    fi
    ((pos++))
  done

  spec=""
  opt=""
  if [[ -n $pend && $_crs_cur != -* ]]; then
    opt=$pend
    k=$node'|'$pend
    spec=${_CRS_ARG[$k]}
  elif [[ -n $multi && $_crs_cur != -* ]]; then
    opt=$multi
    k=$node'|'$multi
    spec=${_CRS_ARG[$k]}
  fi

  if [[ -n $spec ]]; then
    _crs_values "$spec" "$opt" "$node"
    rc=$?
    ((rc == 2)) && return 0
    ((rc == 0)) && _crs_emit "$_crs_prefix" "$_crs_partial"
  elif [[ $_crs_cur == -* && -z $_crs_q ]]; then
    for c in ${_CRS_OPTS[$node]-}; do
      [[ $c == -* && $used != *" $c "* ]] && _crs_cands+=("$c")
    done
    _crs_emit "" "$_crs_cur"
  else
    # sub commands and keywords, then the values of the next positional argument
    if ((pos == 0)); then
      for c in ${_CRS_CHILD[$node]-}; do _crs_cands+=("$c"); done
    fi
    for c in ${_CRS_OPTS[$node]-}; do
      [[ $c != -* && $used != *" $c "* ]] && _crs_cands+=("$c")
    done
    _crs_emit "" "$_crs_cur"
    read -r -a poslist <<<"${_CRS_POS[$node]-}"
    spec=""
    if ((pos < ${#poslist[@]})); then
      spec=${poslist[pos]}
    elif ((${#poslist[@]})) && [[ ${poslist[${#poslist[@]} - 1]} == *'*' ]]; then
      spec=${poslist[${#poslist[@]} - 1]}
    fi
    [[ $node == "set log res" && $pos == 0 ]] && spec=resname=lvl
    if [[ -n $spec ]]; then
      _crs_values "$spec" "" "$node"
      rc=$?
      ((rc == 2)) && return 0
      ((rc == 0)) && _crs_emit "$_crs_prefix" "$_crs_partial"
    fi
    # nothing else to offer: show the options
    if ((${#COMPREPLY[@]} == 0)) && [[ -z $_crs_q ]]; then
      _crs_cands=()
      for c in ${_CRS_OPTS[$node]-}; do
        [[ $c == -* && $used != *" $c "* ]] && _crs_cands+=("$c")
      done
      _crs_emit "" "$_crs_cur"
    fi
  fi

  # no duplicates
  local -A seen=()
  local -a out=()
  for c in "${COMPREPLY[@]}"; do
    [[ -n ${seen[$c]+x} ]] && continue
    seen[$c]=1
    out+=("$c")
  done
  COMPREPLY=("${out[@]}")

  # readline treats "=" and ":" of a word that is not quoted as word breaks
  if [[ -z $_crs_q && $_crs_cur == *[=:]* ]]; then
    local lt=${_crs_cur%"${_crs_cur##*[=:]}"}
    for i in "${!COMPREPLY[@]}"; do COMPREPLY[i]=${COMPREPLY[i]#"$lt"}; done
  fi
  if ((_crs_nospace)) || [[ ${COMPREPLY[0]-} == *[=,] ]]; then
    compopt -o nospace 2>/dev/null
  fi
  return 0
}

complete -F _crsctl_complete crsctl
