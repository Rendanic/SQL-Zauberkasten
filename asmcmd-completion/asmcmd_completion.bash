# shellcheck shell=bash
#
# Version: 1.0
#
# Bash completion for Oracle asmcmd (Oracle Restart / Grid Infrastructure cluster)
#
# Install:   source this file from ~/.bashrc, or copy it to /etc/bash_completion.d/asmcmd
#
# How it works
#  - The command list and the global options are parsed from `asmcmd help`, the options
#    of a command from `asmcmd help <command>`, the first time the command is completed.
#    The result is cached per asmcmd in ${XDG_CACHE_HOME:-~/.cache}/asmcmd-completion/
#    and regenerated automatically when the asmcmd is newer than the cache.
#  - ASM paths (+DATA/DB/DATAFILE/...) are listed live with `asmcmd ls` of the ASM instance
#    that asmcmd connects to (ORACLE_HOME / ORACLE_SID of your shell), so it works
#    for the same user and environment as asmcmd itself. Every listing is one asmcmd
#    call (about a second), the result is cached for ASMCMD_COMP_TTL seconds.
#  - Disk groups come from crsctl (fast, includes dismounted disk groups), asmcmd lsdg is the fallback.
#  - /etc/oratab is never used.
#
# Variables
#   ASMCMD_COMP_TTL     seconds to cache the output of asmcmd and crsctl (default 10)
#   ASMCMD_COMP_CACHE   cache directory for the parsed help output

declare -gA _ASM_OPTS=() _ASM_ARG=() _ASM_ENUM=() _ASM_POS=() _ASM_HAVE=()
declare -gA _ASMCMD_OUT=() _ASMCMD_TS=()
_ASM_CMDS=""
_ASMCMD_BIN=""
_ASMCMD_SIG=""
_asm_r=""

# commands whose arguments are ASM paths (a path without + is relative to the root of ASM)
_ASMCMD_ASMONLY="cd du find ls mkalias mkdir rm rmalias stat chgrp chmod chown mvfile setsparseparent mapblk mapextent chblk"

# ---------------------------------------------------------------------------
# Generator: parse the help of a command into bash associative arrays
# ---------------------------------------------------------------------------

# stdin: `asmcmd help [<command>]`, $1 = command ("asmcmd" for the global options)
_asmcmd_comp_awk() {
  awk -v cmd="$1" '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function q(s) { gsub(/\047/, "", s); return "\047" s "\047" }
    function add_tok(t, v) { nt++; tt[nt] = t; tk[nt] = v }

    # <files...> -> files*, <diskgroups,...> -> diskgroups,*, <[connect_str:]src_file...> -> src_file*
    function phspec(t,   multi, comma) {
      gsub(/\[[^]]*\]/, "", t)
      gsub(/\047/, "", t)
      multi = (t ~ /\.\.\.$/); sub(/\.\.\.$/, "", t)
      comma = (t ~ /,$/); sub(/,$/, "", t)
      gsub(/[ \t]+/, "_", t)
      return t (comma ? "," : "") (multi ? "*" : "")
    }

    function unbalanced(s,   i, c, d) {
      d = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (c == "[" || c == "{") d++
        else if (c == "]" || c == "}") d--
      }
      return d
    }

    function tokenize(s,   i, n, c, j, w, k) {
      nt = 0; n = length(s); i = 1
      while (i <= n) {
        c = substr(s, i, 1)
        if (c == " " || c == "\t") { i++; continue }
        if (c == "<") {
          j = index(substr(s, i), ">")
          if (j == 0) break
          add_tok("PH", substr(s, i + 1, j - 2)); i += j; continue
        }
        if (c == "-" && substr(s, i + 1, 1) ~ /[-A-Za-z]/) {
          match(substr(s, i), /^--?[A-Za-z][A-Za-z0-9_]*/)
          if (RLENGTH < 2) { i++; continue }
          w = substr(s, i, RLENGTH); i += RLENGTH
          if (substr(w, 2, 1) != "-" && length(w) > 2) {
            for (k = 2; k <= length(w); k++) add_tok("FLAG", "-" substr(w, k, 1))
          } else add_tok("OPT", w)
          continue
        }
        if (c ~ /[][{}|]/) { add_tok(c, c); i++; continue }
        if (c ~ /[A-Za-z0-9_]/) {
          match(substr(s, i), /^[A-Za-z0-9_]+/)
          add_tok("WORD", substr(s, i, RLENGTH)); i += RLENGTH; continue
        }
        i++
      }
    }

    # value of the option at token j: sets vname, venum, vskip
    function vspec(j,   k, d, n, e, ok, ev) {
      vname = ""; venum = ""; vskip = 0
      k = j + 1
      if (tt[k] == "PH") { vname = phspec(tk[k]); vskip = 1; return }
      if (tt[k] == "{") {
        d = 0; e = 0
        for (n = k; n <= nt; n++) {
          if (tt[n] == "{" || tt[n] == "[") d++
          else if (tt[n] == "}" || tt[n] == "]") { d--; if (d == 0) { e = n; break } }
        }
        if (e == 0) return
        ok = 1; ev = ""
        for (n = k + 1; n < e; n++) {
          if (tt[n] == "|") continue
          if (tt[n] == "WORD" && (tt[n - 1] == "{" || tt[n - 1] == "|") && (tt[n + 1] == "|" || tt[n + 1] == "}")) ev = ev " " tk[n]
          else ok = 0
        }
        if (ok && ev != "") { venum = trim(ev); vname = "enum"; vskip = e - j; return }
        if (tt[k + 1] == "PH") { vname = phspec(tk[k + 1]); vskip = e - j }
      }
    }

    function reg_opt(o) { if (!(o in hasopt)) { hasopt[o] = 1; opts = opts " " o } }
    function reg_arg(o, nm, en,   w, nw, i) {
      if (!(o in hasarg)) { hasarg[o] = 1; argkeys[++na] = o; arg[o] = nm }
      if (en != "") {
        nw = split(en, w, " ")
        for (i = 1; i <= nw; i++) if (index(" " enm[o] " ", " " w[i] " ") == 0) enm[o] = trim(enm[o] " " w[i])
      }
    }
    function reg_pos(nm,   base) {
      base = nm; sub(/[,*]+$/, "", base)
      if (base == "" || base == "command" && cmd == "asmcmd") return
      if (!(base in haspos)) { haspos[base] = 1; pos = pos " " nm }
    }

    function parse(rest,   j, t) {
      tokenize(rest)
      for (j = 1; j <= nt; j++) {
        t = tt[j]
        if (t == "FLAG") reg_opt(tk[j])
        else if (t == "OPT") {
          reg_opt(tk[j])
          vspec(j)
          if (vname != "") { reg_arg(tk[j], vname, venum); j += vskip }
        } else if (t == "PH") reg_pos(phspec(tk[j]))
      }
    }

    function flush() { if (started) parse(cur); cur = ""; started = 0 }

    /^Synopsis[ \t]*$/ { insyn = 1; next }
    insyn && /^[ \t]*$/ { insyn = 0; next }
    insyn {
      line = trim($0)
      if (line ~ ("^" cmd "([ \t]|$)")) { flush(); cur = substr(line, length(cmd) + 1); started = 1 }
      else if (started && (line ~ /^[{[<-]/ || unbalanced(cur) > 0 || cur ~ /\|[ \t]*$/)) cur = cur " " line
    }
    END {
      flush()
      print "_ASM_OPTS[" q(cmd) "]=" q(trim(opts))
      print "_ASM_POS[" q(cmd) "]=" q(trim(pos))
      for (i = 1; i <= na; i++) {
        print "_ASM_ARG[" q(cmd "|" argkeys[i]) "]=" q(arg[argkeys[i]])
        if (argkeys[i] in enm) print "_ASM_ENUM[" q(cmd "|" argkeys[i]) "]=" q(enm[argkeys[i]])
      }
    }'
}

# ---------------------------------------------------------------------------
# Binary, cache
# ---------------------------------------------------------------------------

# $1 = command word as typed. Sets _ASMCMD_BIN.
_asmcmd_comp_findbin() {
  local b
  b=$(type -P -- "$1" 2>/dev/null)
  if [[ -z $b && -n ${ORACLE_HOME:-} && -x $ORACLE_HOME/bin/asmcmd ]]; then
    b=$ORACLE_HOME/bin/asmcmd
  fi
  [[ -n $b ]] || return 1
  _ASMCMD_BIN=$b
}

# runs asmcmd with a time limit
_asmcmd_comp_exec() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 30 "$_ASMCMD_BIN" "$@" 2>/dev/null
  else
    "$_ASMCMD_BIN" "$@" 2>/dev/null
  fi
}

# command list and global options
_asmcmd_comp_gen_top() {
  local txt cmds
  txt=$(_asmcmd_comp_exec help)
  [[ -n $txt ]] || return 1
  cmds=$(awk '/^[ \t]*commands:/ { f = 1; next }
    f { gsub(/,/, " "); for (i = 1; i <= NF; i++) if ($i ~ /^[a-z][a-z0-9_]*$/ && !seen[$i]++) printf "%s ", $i }' <<<"$txt")
  [[ -n $cmds ]] || return 1
  printf "_ASM_CMDS='%s'\n" "${cmds% }"
  _asmcmd_comp_awk asmcmd <<<"$txt"
}

# $1 = file to be generated, rest = generator command. Rebuilds when the file is missing or older than asmcmd.
_asmcmd_comp_cached() {
  local file=$1 real
  shift
  real=$(readlink -f -- "$_ASMCMD_BIN" 2>/dev/null || printf '%s' "$_ASMCMD_BIN")
  if [[ ! -s $file || $real -nt $file ]]; then
    mkdir -p -- "${file%/*}" 2>/dev/null || return 1
    if "$@" >"$file.$$" 2>/dev/null && [[ -s $file.$$ ]]; then
      mv -f -- "$file.$$" "$file"
    fi
    rm -f -- "$file.$$"
  fi
  [[ -s $file ]]
}

# finds asmcmd, loads the command list. $1 = command word as typed.
_asmcmd_comp_init() {
  local real sig dir
  _asmcmd_comp_findbin "$1" || return 1
  real=$(readlink -f -- "$_ASMCMD_BIN" 2>/dev/null || printf '%s' "$_ASMCMD_BIN")
  sig=${real//\//_}
  dir=${ASMCMD_COMP_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/asmcmd-completion}
  if [[ $_ASMCMD_SIG != "$sig" ]]; then
    _ASM_OPTS=() _ASM_ARG=() _ASM_ENUM=() _ASM_POS=() _ASM_HAVE=()
    _ASM_CMDS=""
    _ASMCMD_SIG=$sig
  fi
  _ASMCMD_DIR=$dir
  [[ -n $_ASM_CMDS ]] && return 0
  _asmcmd_comp_cached "$dir/$sig.top.bash" _asmcmd_comp_gen_top || return 1
  # shellcheck disable=SC1090
  source "$dir/$sig.top.bash"
  [[ -n $_ASM_CMDS ]]
}

# the help of one command, read the first time the command is completed
_asmcmd_comp_gen_cmd() {
  _asmcmd_comp_exec help "$1" | _asmcmd_comp_awk "$1"
}

_asmcmd_comp_load_cmd() {
  local file
  [[ -n ${_ASM_HAVE[$1]+x} ]] && return 0
  file=$_ASMCMD_DIR/$_ASMCMD_SIG.cmd_$1.bash
  _asmcmd_comp_cached "$file" _asmcmd_comp_gen_cmd "$1" || return 1
  # shellcheck disable=SC1090
  source "$file" || return 1
  _ASM_HAVE[$1]=1
}

# ---------------------------------------------------------------------------
# Live data
# ---------------------------------------------------------------------------

# $@ = asmcmd arguments. Result in _asm_r (not on stdout: a subshell would lose the cache).
_asm_run() {
  local key="$_ASMCMD_BIN $*" now ts ttl=${ASMCMD_COMP_TTL:-10}
  now=${EPOCHSECONDS:-$(date +%s)}
  ts=${_ASMCMD_TS[$key]:-0}
  if ((now - ts < ttl)) && [[ -n ${_ASMCMD_OUT[$key]+x} ]]; then
    _asm_r=${_ASMCMD_OUT[$key]}
    return 0
  fi
  _asm_r=$(_asmcmd_comp_exec "$@")
  _ASMCMD_OUT[$key]=$_asm_r
  _ASMCMD_TS[$key]=$now
}

# Disk groups: crsctl of the home of asmcmd (also dismounted disk groups), else asmcmd lsdg
_asm_dgs() {
  local crsctl=${_ASMCMD_BIN%/bin/*}/bin/crsctl l n key now ts ttl=${ASMCMD_COMP_TTL:-10}
  _asm_cands=()
  if [[ -x $crsctl ]]; then
    key="$crsctl dg"
    now=${EPOCHSECONDS:-$(date +%s)}
    ts=${_ASMCMD_TS[$key]:-0}
    if ((now - ts < ttl)) && [[ -n ${_ASMCMD_OUT[$key]+x} ]]; then
      _asm_r=${_ASMCMD_OUT[$key]}
    else
      _asm_r=$("$crsctl" status resource -w "TYPE = ora.diskgroup.type" 2>/dev/null)
      _ASMCMD_OUT[$key]=$_asm_r
      _ASMCMD_TS[$key]=$now
    fi
    while IFS= read -r l; do
      if [[ $l == NAME=ora.* ]]; then
        # resources of a resource group are listed as name(group)
        n=${l#NAME=ora.}
        n=${n%%(*}
        _asm_cands+=("${n%.dg}")
      fi
    done <<<"$_asm_r"
  fi
  ((${#_asm_cands[@]})) && return 0
  _asm_run lsdg --suppressheader
  while IFS= read -r l; do
    n=${l##* }
    [[ -n $n ]] && _asm_cands+=("${n%/}")
  done <<<"$_asm_r"
}

# attribute names of the disk group given with -G
_asm_attrs() {
  local dg="" i l
  _asm_cands=()
  for ((i = 0; i < ${#_asm_w[@]}; i++)); do
    [[ ${_asm_w[i]} == -G ]] && dg=${_asm_w[i + 1]-}
  done
  [[ -n $dg ]] || return 0
  _asm_run lsattr -G "$dg" --suppressheader
  while IFS= read -r l; do
    l=${l%%[[:space:]]*}
    [[ -n $l ]] && _asm_cands+=("$l")
  done <<<"$_asm_r"
}

# ASM paths or file names. $1 = asm|mixed, $2 = 1: directories only.
# Fills COMPREPLY (file name completion). A path without + is relative to the root of ASM.
_asm_paths() {
  local mode=$1 dironly=$2 v=$_asm_cur plus="" p dirpart leaf e c n=0 alldir=1
  local -a list=()
  COMPREPLY=()
  if [[ $mode == mixed && $v != +* ]]; then
    compopt -o filenames 2>/dev/null
    mapfile -t COMPREPLY < <(compgen -f -- "$v")
    return 0
  fi
  [[ $v == +* ]] && plus=+
  p=${v#+}
  leaf=${p##*/}
  dirpart=${p%"$leaf"}
  _asm_run ls "+$dirpart"
  while IFS= read -r e; do
    [[ -n $e && $e != ASMCMD-* ]] || continue
    ((dironly)) && [[ $e != */ ]] && continue
    [[ ${e,,} == "${leaf,,}"* ]] && list+=("$plus$dirpart$e")
  done <<<"$_asm_r"
  # no entry of the root without +: not needed, "ls +" lists the disk groups too
  COMPREPLY=("${list[@]}")
  compopt -o filenames 2>/dev/null
  for c in "${COMPREPLY[@]}"; do
    ((n++))
    [[ $c == */ ]] || alldir=0
  done
  # directories: go on with the next level without a space
  if ((n && alldir)); then compopt -o nospace 2>/dev/null; fi
}

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------

# Splits the command line up to the cursor like the shell does (quotes, backslash).
# Sets _asm_w (finished words), _asm_cur (word at the cursor, without quote), _asm_q (open quote).
_asm_split() {
  local s=$1 i ch q="" word="" have=0 n=${#1}
  _asm_w=()
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
          _asm_w+=("$word")
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
  _asm_cur=$word
  _asm_q=$q
}

# Kind of the values of a placeholder. $1 = placeholder, $2 = command, $3 = option ("" = positional)
_asm_kind() {
  local ph=${1,,}
  _asm_kindv=""
  ph=${ph%%[,*]*}
  case $ph in
    diskgroup | diskgroups | dg_name) _asm_kindv=diskgroup ;;
    attribute_name) _asm_kindv=attr ;;
    command) [[ $2 == help ]] && _asm_kindv="command" ;;
    dir | directories) _asm_kindv=asmdir ;;
    *)
      if [[ " $_ASMCMD_ASMONLY " == *" $2 "* ]]; then
        case $ph in
          pattern) [[ $2 != find ]] && _asm_kindv=asmpath ;;
          names | name | file | files | alias | aliases | child_file | parent_file) _asm_kindv=asmpath ;;
        esac
      fi
      if [[ -z $_asm_kindv ]]; then
        case $ph in
          pattern) [[ $2 == lsdg ]] && _asm_kindv=diskgroup ;;
          *file* | *path* | *xml* | wrap | source | destination | location) _asm_kindv=mixed ;;
        esac
      fi
      ;;
  esac
}

# Candidates for the value described by a placeholder. $1 = spec, $2 = option or "", $3 = command
# Fills _asm_cands, _asm_prefix (kept in front of every candidate) and _asm_partial (what is matched).
# Returns 1 = nothing to offer, 2 = COMPREPLY was filled directly (paths, file names).
_asm_values() {
  local spec=$1 opt=$2 cmd=$3 comma=0 v=$_asm_cur k
  _asm_cands=()
  _asm_prefix=""
  _asm_partial=$v
  [[ $spec == *,* ]] && comma=1
  spec=${spec%%[,*]*}

  if ((comma)); then
    _asm_nospace=1
    if [[ $v == *,* ]]; then
      _asm_partial=${v##*,}
      _asm_prefix=${v%"$_asm_partial"}
    fi
  fi

  if [[ $spec == enum ]]; then
    k=$cmd'|'$opt
    read -r -a _asm_cands <<<"${_ASM_ENUM[$k]-}"
    return 0
  fi

  _asm_kind "$spec" "$cmd" "$opt"
  case $_asm_kindv in
    diskgroup) _asm_dgs ;;
    attr) _asm_attrs ;;
    command) read -r -a _asm_cands <<<"$_ASM_CMDS" ;;
    asmdir)
      _asm_paths asm 1
      return 2
      ;;
    asmpath)
      _asm_paths asm 0
      return 2
      ;;
    mixed)
      _asm_paths mixed 0
      return 2
      ;;
    *) return 1 ;;
  esac
  return 0
}

# appends the candidates that start with $2 to COMPREPLY, each with the open quote and $1 in front
_asm_emit() {
  local c listed=,${1%,},
  for c in "${_asm_cands[@]}"; do
    # entries that are already in a comma separated list are not offered again
    [[ -n $1 && $listed == *,"$c",* ]] && continue
    [[ $c == "$2"* ]] && COMPREPLY+=("$_asm_q$1$c")
  done
}

_asmcmd_complete() {
  local i j k w c cmd opt spec pend="" gpend="" multi="" pos=0 used=" " rc
  local -a poslist=()
  COMPREPLY=()
  _asm_w=()
  _asm_cands=()
  _asm_nospace=0
  _asm_prefix=""
  _asm_partial=""

  _asm_split "${COMP_LINE:0:COMP_POINT}"
  # "sudo asmcmd ...": drop everything in front of asmcmd
  for ((i = 0; i < ${#_asm_w[@]}; i++)); do
    [[ ${_asm_w[i]##*/} == asmcmd ]] && break
  done
  ((i < ${#_asm_w[@]})) || i=0
  _asm_w=("${_asm_w[@]:i}")
  _asmcmd_comp_init "${_asm_w[0]:-asmcmd}" || return 0

  # global options, then the command
  i=1
  cmd=""
  while ((i < ${#_asm_w[@]})); do
    w=${_asm_w[i]}
    if [[ $w == -* ]]; then
      k=asmcmd'|'$w
      if [[ -n ${_ASM_ARG[$k]+x} ]]; then
        if ((i + 1 >= ${#_asm_w[@]})); then
          gpend=$w
          break
        fi
        ((i += 2))
      else
        ((i++))
      fi
      continue
    fi
    cmd=$w
    ((i++))
    break
  done

  if [[ -z $cmd ]]; then
    if [[ -n $gpend && $_asm_cur != -* ]]; then
      k=asmcmd'|'$gpend
      [[ ${_ASM_ARG[$k]-} == enum ]] && read -r -a _asm_cands <<<"${_ASM_ENUM[$k]-}"
    elif [[ $_asm_cur == -* ]]; then
      read -r -a _asm_cands <<<"${_ASM_OPTS[asmcmd]-}"
    else
      read -r -a _asm_cands <<<"$_ASM_CMDS"
    fi
    _asm_emit "" "$_asm_cur"
    return 0
  fi

  [[ " $_ASM_CMDS " == *" $cmd "* ]] || return 0
  _asmcmd_comp_load_cmd "$cmd" || return 0

  # arguments behind the command: options with values, positional arguments
  for ((j = i; j < ${#_asm_w[@]}; j++)); do
    w=${_asm_w[j]}
    if [[ -n $pend && $w != -* ]]; then
      k=$cmd'|'$pend
      [[ ${_ASM_ARG[$k]-} == *'*' ]] && multi=$pend
      pend=""
      continue
    fi
    if [[ -n $multi && $w != -* ]]; then
      continue
    fi
    if [[ " ${_ASM_OPTS[$cmd]-} " == *" $w "* ]]; then
      used+="$w "
      multi=""
      k=$cmd'|'$w
      pend=""
      [[ -n ${_ASM_ARG[$k]+x} ]] && pend=$w
      continue
    fi
    ((pos++))
  done

  spec=""
  opt=""
  if [[ -n $pend && $_asm_cur != -* ]]; then
    opt=$pend
    k=$cmd'|'$pend
    spec=${_ASM_ARG[$k]}
  elif [[ -n $multi && $_asm_cur != -* ]]; then
    opt=$multi
    k=$cmd'|'$multi
    spec=${_ASM_ARG[$k]}
  fi

  if [[ -z $spec && ($_asm_cur != -* || -n $_asm_q) ]]; then
    read -r -a poslist <<<"${_ASM_POS[$cmd]-}"
    if ((pos < ${#poslist[@]})); then
      spec=${poslist[pos]}
    elif ((${#poslist[@]})) && [[ ${poslist[${#poslist[@]} - 1]} == *'*' ]]; then
      spec=${poslist[${#poslist[@]} - 1]}
    fi
    opt=""
  fi

  if [[ -n $spec ]]; then
    _asm_values "$spec" "$opt" "$cmd"
    rc=$?
    ((rc == 2)) && return 0
    ((rc == 0)) && _asm_emit "$_asm_prefix" "$_asm_partial"
  fi

  # options (also when there is nothing else to offer)
  if [[ $_asm_cur == -* && -z $_asm_q ]] || ((${#COMPREPLY[@]} == 0)) && [[ -z $_asm_q ]]; then
    _asm_cands=()
    for c in ${_ASM_OPTS[$cmd]-}; do
      [[ $used != *" $c "* ]] && _asm_cands+=("$c")
    done
    _asm_emit "" "$_asm_cur"
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
  if ((_asm_nospace)); then
    compopt -o nospace 2>/dev/null
  fi
  return 0
}

complete -F _asmcmd_complete asmcmd
