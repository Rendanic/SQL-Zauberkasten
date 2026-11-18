# shellcheck shell=bash
#
# Version: 1.0
#
# Bash completion for Oracle srvctl (Oracle Restart / Grid Infrastructure / RAC)
#
# Install:   source this file from ~/.bashrc, or copy it to /etc/bash_completion.d/srvctl
#
# How it works
#  - Verbs, objects, options and enum values are parsed from `srvctl -h` of the
#    srvctl binary that is actually called (19c, 26ai, Restart, RAC ...).
#    The result is cached per binary in ${XDG_CACHE_HOME:-~/.cache}/srvctl-completion/
#    and regenerated automatically when the srvctl binary is newer than the cache.
#  - Resource names (-db, -service, -pdb, -listener, -diskgroup, -instance, -node)
#    are read live from the clusterware via `crsctl stat res -p` (fast, independent
#    of the database version). The result is cached for SRVCTL_COMP_TTL seconds.
#  - The GI/Restart home is taken from /etc/oracle/olr.loc (crs_home=), fallback
#    is $ORACLE_HOME/bin/crsctl or crsctl from PATH. /etc/oratab is never used.
#
# Variables
#   SRVCTL_COMP_TTL     seconds to cache the crsctl output (default 10)
#   SRVCTL_COMP_CACHE   cache directory for the parsed help output

# ---------------------------------------------------------------------------
# Generator: parse `srvctl -h` into bash associative arrays
# ---------------------------------------------------------------------------
_srvctl_comp_gen() {
    # $1 = path of srvctl binary
    local srvctl=$1 ohome tmp v
    ohome=${srvctl%/bin/srvctl}
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/srvctl-comp.XXXXXX") || return 1
    # The global help and the per-verb help are both incomplete (e.g. 26ai:
    # `status listener` only in `srvctl status -h`) => parse the union.
    # srvctl is a slow Java tool, so the per-verb calls run in parallel.
    ORACLE_HOME=$ohome "$srvctl" -h >"$tmp/_all" 2>/dev/null
    # shellcheck disable=SC2013  # verbs are single words
    for v in $(sed -n 's/^Usage: srvctl \([a-z][a-z]*\) .*/\1/p' "$tmp/_all" | sort -u); do
        ORACLE_HOME=$ohome "$srvctl" "$v" -h >"$tmp/$v" 2>/dev/null &
    done
    wait
    cat "$tmp"/* | awk '
        function q(s) { gsub(/\047/, "", s); return "\047" s "\047" }
        function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
        function enumvals(s,   n, i, a, out, v) {
            # s like "A | B | C" or "[A][,B][,C]"
            gsub(/[\[\]{}<>,|]/, " ", s)
            n = split(s, a, /[ \t]+/)
            out = ""
            for (i = 1; i <= n; i++) {
                v = a[i]
                if (v ~ /^[A-Z][A-Z0-9_]*$/ && index(" " out " ", " " v " ") == 0)
                    out = out (out == "" ? "" : " ") v
            }
            return out
        }
        function handle(line,   w, verb, obj, key, rest, opt, after, a, c, ph, ev, p) {
            sub(/^Usage: srvctl[ \t]+/, "", line)
            split(line, w, /[ \t]+/)
            verb = w[1]; obj = w[2]
            if (verb !~ /^[a-z]+$/ || obj !~ /^[a-z_]+$/) return
            if (!(verb in seenverb)) { seenverb[verb] = 1; verbs = verbs " " verb }
            if (!((verb, obj) in seenobj)) { seenobj[verb, obj] = 1; objs[verb] = objs[verb] " " obj }
            key = verb ":" obj
            if (!(key in opts)) { opts[key] = ""; keys[++nkeys] = key }
            rest = substr(line, index(line, obj) + length(obj))
            while (match(rest, /(^|[ \t\[{|"])-[a-zA-Z][a-zA-Z0-9_]*/)) {
                opt = substr(rest, RSTART, RLENGTH)
                sub(/^[^-]/, "", opt)
                after = substr(rest, RSTART + RLENGTH)
                rest = after
                if (index(" " opts[key] " ", " " opt " ") == 0)
                    opts[key] = opts[key] " " opt
                if (after !~ /^([ \t]|$)/) continue          # "-force]", "-all |" ... => flag
                a = after; sub(/^[ \t]+/, "", a)
                c = substr(a, 1, 1)
                if (c == "\047" || c == "\"") {               # quoted value, e.g. "<list>" or {YES|NO} in single quotes
                    p = index(substr(a, 2), c); a = substr(a, 2, p - 1); c = substr(a, 1, 1)
                }
                ph = ""; ev = ""
                if (c == "{") {
                    p = index(a, "}"); ev = enumvals(substr(a, 2, p - 2)); ph = "enum"
                } else if (c == "<") {
                    p = index(a, ">"); ph = substr(a, 2, p - 2)
                    if (ph ~ /\|/ || ph ~ /^\[?[A-Z][A-Z0-9_]*\]?(\[|$)/) { ev = enumvals(ph); ph = "enum" }
                } else if (a ~ /^\[[A-Z]/) {
                    match(a, /^(\[[^\]-]*\])+/); ev = enumvals(substr(a, 1, RLENGTH)); ph = "enum"
                } else if (a ~ /^[A-Z][A-Z0-9_]*([ \t\]]|$)/) {
                    # literal value, e.g. "convert database -dbtype RAC"
                    match(a, /^[A-Z][A-Z0-9_]*/); ev = substr(a, 1, RLENGTH); ph = "enum"
                } else if (a ~ /^[a-z][a-z0-9_]*([ \t\]]|$)/ && a !~ /^-/) {
                    # bare placeholder without brackets (rare)
                    match(a, /^[a-z][a-z0-9_]*/); ph = substr(a, 1, RLENGTH)
                }
                gsub(/[<>"]/, "", ph)
                if (ph != "" && !((key, opt) in arg)) { arg[key, opt] = trim(ph); argk[++nargs] = key SUBSEP opt }
                if (ev != "") enums[key, opt] = enumvals(enums[key, opt] " " ev)   # union over all usage lines
            }
        }
        /^Usage:/ { if (cur != "") handle(cur); cur = $0; next }
        /^[ \t]/  { if (cur != "") cur = cur " " $0; next }
                  { if (cur != "") handle(cur); cur = "" }
        END {
            if (cur != "") handle(cur)
            print "_SRVCTL_VERBS=" q(trim(verbs))
            print "declare -gA _SRVCTL_OBJS=()"
            for (v in objs) print "_SRVCTL_OBJS[" v "]=" q(trim(objs[v]))
            print "declare -gA _SRVCTL_OPTS=()"
            for (i = 1; i <= nkeys; i++) print "_SRVCTL_OPTS[" keys[i] "]=" q(trim(opts[keys[i]]))
            print "declare -gA _SRVCTL_ARG=()"
            print "declare -gA _SRVCTL_ENUM=()"
            for (i = 1; i <= nargs; i++) {
                split(argk[i], p, SUBSEP)
                print "_SRVCTL_ARG[" p[1] ":" p[2] "]=" q(arg[p[1], p[2]])
                if ((p[1], p[2]) in enums) print "_SRVCTL_ENUM[" p[1] ":" p[2] "]=" q(enums[p[1], p[2]])
            }
        }'
    rm -rf -- "$tmp"
}

_srvctl_comp_load() {
    # $1 = command as typed (srvctl or a path)
    local srvctl dir file
    srvctl=$(type -P -- "$1" 2>/dev/null) || return 1
    srvctl=$(readlink -f -- "$srvctl" 2>/dev/null || echo "$srvctl")
    [[ $_SRVCTL_LOADED == "$srvctl" ]] && return 0

    dir=${SRVCTL_COMP_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/srvctl-completion}
    # srvctl shows different commands for Restart and cluster => mode is part of the
    # cache key (matters for a $HOME shared between hosts or a Restart -> cluster conversion)
    file=$dir/${srvctl//\//_}.$(_srvctl_comp_mode).bash
    if [[ ! -s $file || $srvctl -nt $file ]]; then
        mkdir -p -- "$dir" 2>/dev/null || return 1
        _srvctl_comp_gen "$srvctl" >"$file.$$" 2>/dev/null && mv -f -- "$file.$$" "$file"
        rm -f -- "$file.$$"
    fi
    [[ -s $file ]] || return 1
    unset _SRVCTL_VERBS _SRVCTL_OBJS _SRVCTL_OPTS _SRVCTL_ARG _SRVCTL_ENUM
    # shellcheck disable=SC1090
    source "$file" || return 1
    _SRVCTL_LOADED=$srvctl
}

# ---------------------------------------------------------------------------
# Live resource data from crsctl
# ---------------------------------------------------------------------------

# "restart" (Oracle Restart / single node), "cluster" (GI cluster / RAC) or "none"
_srvctl_comp_mode() {
    local lo
    [[ -r /etc/oracle/ocr.loc ]] || { echo none; return; }
    lo=$(sed -n 's/^local_only=//p' /etc/oracle/ocr.loc 2>/dev/null)
    if [[ ${lo^^} == TRUE ]]; then echo restart; else echo cluster; fi
}

_srvctl_comp_crshome() {
    local h
    if [[ -r /etc/oracle/olr.loc ]]; then
        h=$(sed -n 's/^crs_home=//p' /etc/oracle/olr.loc 2>/dev/null)
        [[ -x $h/bin/crsctl ]] && { echo "$h"; return; }
    fi
    [[ -n $ORACLE_HOME && -x $ORACLE_HOME/bin/crsctl ]] && { echo "$ORACLE_HOME"; return; }
    h=$(type -P crsctl 2>/dev/null) && echo "${h%/bin/crsctl}"
}

# Prints lines "<kind> <db> <value> [<node>]" (db column "-" if n/a)
#   all:     db, inst, svc, pdb, lsnr, dg
#   cluster: net (network number), vip, scan (scan number), scanname, vol, dev
_srvctl_comp_resources() {
    local now=${EPOCHSECONDS:-$(date +%s)} home
    if [[ -n $_SRVCTL_RES_TS ]] && (( now - _SRVCTL_RES_TS < ${SRVCTL_COMP_TTL:-10} )); then
        printf '%s' "$_SRVCTL_RES"
        return
    fi
    home=$(_srvctl_comp_crshome) || return
    [[ -n $home ]] || return
    _SRVCTL_RES=$("$home/bin/crsctl" stat res -p 2>/dev/null | awk '
        function flush(   n, a, k) {
            if (name == "") return
            n = split(name, a, ".")
            if (type == "ora.database.type") {
                dbmap[a[2]] = dbu; print "db - " dbu
                for (k in inst) print "inst " dbu " " k " " inst[k]
            } else if (type == "ora.network.type") {
                sub(/^net/, "", a[2]); print "net - " a[2]
            } else if (type ~ /^ora\.cluster_vip_net[0-9]+\.type$/) {
                print "vip - " (vip != "" ? vip : a[2]) " " a[2]
            } else if (type == "ora.scan_vip.type") {
                sub(/^scan/, "", a[2]); print "scan - " a[2]
                if (scanname != "") print "scanname - " scanname
            } else if (type == "ora.volume.type") {
                if (volname != "") print "vol - " volname
                if (voldev != "") print "dev - " voldev
            } else if (type == "ora.service.type") {
                svc[++ns] = a[2] " " (sname != "" ? sname : a[3])
                if (pdb != "") pdbs[++np] = a[2] " " pdb
            } else if (type == "ora.pdb.type") {
                pdbs[++np] = a[2] " " (pdb != "" ? pdb : a[3])
            } else if (type == "ora.listener.type") {
                l = name; sub(/^ora\./, "", l); sub(/\.lsnr$/, "", l); print "lsnr - " l
            } else if (type == "ora.diskgroup.type") {
                print "dg - " a[2]
            }
            name = type = dbu = sname = pdb = vip = scanname = volname = voldev = ""; delete inst
        }
        /^NAME=/                { flush(); name = substr($0, 6); next }
        /^TYPE=/                { type = substr($0, 6); next }
        /^DB_UNIQUE_NAME=/      { dbu = substr($0, 16); next }
        /^SERVICE_NAME=/        { sname = substr($0, 14); next }
        /^PDB_NAME=/            { pdb = substr($0, 10); next }
        /^PLUGGABLE_DATABASE=/  { pdb = substr($0, 20); next }
        /^USR_ORA_VIP=/         { vip = substr($0, 13); next }
        /^SCAN_NAME=/           { scanname = substr($0, 11); next }
        /^VOLUME_NAME=/         { volname = substr($0, 13); next }
        /^VOLUME_DEVICE=/       { voldev = substr($0, 15); next }
        # Restart: USR_ORA_INST_NAME=X, cluster: GEN_USR_ORA_INST_NAME@SERVERNAME(node)=X
        /^(GEN_)?USR_ORA_INST_NAME(@SERVERNAME\([^)]*\))?=./ {
            v = substr($0, index($0, "=") + 1); n = "-"
            if (match($0, /@SERVERNAME\([^)]*\)/)) n = substr($0, RSTART + 12, RLENGTH - 13)
            if (!(v in inst) || inst[v] == "-") inst[v] = n
            next }
        END {
            flush()
            for (i = 1; i <= ns; i++) { split(svc[i], a, " "); d = (a[1] in dbmap) ? dbmap[a[1]] : a[1]; print "svc " d " " a[2] }
            for (i = 1; i <= np; i++) { split(pdbs[i], a, " "); d = (a[1] in dbmap) ? dbmap[a[1]] : a[1]; print "pdb " d " " a[2] }
        }' | sort -u)
    _SRVCTL_RES_TS=$now
    printf '%s' "$_SRVCTL_RES"
}

# $1 = kind, $2 = db filter, $3 = node filter (both optional, case-insensitive)
_srvctl_comp_res() {
    local kind=$1 db=${2,,} node=${3,,} k d v n
    while read -r k d v n; do
        [[ $k == "$kind" ]] || continue
        [[ -z $db || $d == - || ${d,,} == "$db" ]] || continue
        [[ -z $node || -z $n || $n == - || ${n,,} == "$node" ]] || continue
        printf '%s\n' "$v"
    done <<<"$(_srvctl_comp_resources)"
}

_srvctl_comp_homes() {
    local inv
    inv=$(sed -n 's/^inventory_loc=//p' /etc/oraInst.loc 2>/dev/null)
    [[ -r $inv/ContentsXML/inventory.xml ]] || return
    sed -n '/REMOVED="T"/d; s/.*<HOME .*LOC="\([^"]*\)".*/\1/p' "$inv/ContentsXML/inventory.xml"
}

# Restart: only the local host.
# Cluster: olsnodes. If the stack is down (olsnodes needs CSS), fall back to the node list
# from the installation: inventory NODE_LIST (19c) or NODE_NAME_LIST in crsconfig_params (26ai).
_srvctl_comp_nodes() {
    local home out inv
    if [[ $(_srvctl_comp_mode) != cluster ]]; then
        hostname -s
        return
    fi
    home=$(_srvctl_comp_crshome)
    if [[ -n $home && -x $home/bin/olsnodes ]]; then
        out=$("$home/bin/olsnodes" 2>/dev/null) && [[ -n $out ]] && { printf '%s\n' "$out"; return; }
    fi
    inv=$(sed -n 's/^inventory_loc=//p' /etc/oraInst.loc 2>/dev/null)
    if [[ -n $home && -r $inv/ContentsXML/inventory.xml ]]; then
        out=$(awk -v h="$home" '
            /<HOME / && index($0, "LOC=\"" h "\"") { inhome = ($0 !~ /\/>[ \t]*$/) }
            inhome && /<NODE / { if (match($0, /NAME="[^"]*"/)) print substr($0, RSTART + 6, RLENGTH - 7) }
            inhome && /<\/HOME>/ { exit }' "$inv/ContentsXML/inventory.xml")
        [[ -n $out ]] && { printf '%s\n' "$out"; return; }
    fi
    if [[ -n $home && -r $home/crs/install/crsconfig_params ]]; then
        out=$(sed -n 's/^NODE_NAME_LIST=//p' "$home/crs/install/crsconfig_params" | tr ',' '\n')
        [[ -n $out ]] && { printf '%s\n' "$out"; return; }
    fi
    hostname -s
}

# ---------------------------------------------------------------------------
# Completion function
# ---------------------------------------------------------------------------
# shellcheck disable=SC2153  # _SRVCTL_* arrays are defined in the sourced cache file
_srvctl_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD-1]}
    local verb=${COMP_WORDS[1]} obj=${COMP_WORDS[2]} key ph vals="" i db="" node="" w k skip=""
    COMPREPLY=()

    _srvctl_comp_load "${COMP_WORDS[0]}" || return 0

    if (( COMP_CWORD == 1 )); then
        mapfile -t COMPREPLY < <(compgen -W "$_SRVCTL_VERBS -version -fullversion -help" -- "$cur")
        return 0
    fi
    if (( COMP_CWORD == 2 )); then
        mapfile -t COMPREPLY < <(compgen -W "${_SRVCTL_OBJS[$verb]}" -- "$cur")
        return 0
    fi

    key=$verb:$obj
    [[ -n ${_SRVCTL_OPTS[$key]+x} ]] || return 0

    # value for the previous option?
    if [[ $prev == -* && -n ${_SRVCTL_ARG[$key:$prev]+x} ]]; then
        ph=${_SRVCTL_ARG[$key:$prev]}

        # -db / -node given on the command line filter services, pdbs and instances
        for (( i = 3; i < COMP_CWORD - 1; i++ )); do
            case ${COMP_WORDS[i]} in
                -db)   db=${COMP_WORDS[i+1]//\"/} ;;
                -node) [[ ${COMP_WORDS[i+1]} != *,* ]] && node=${COMP_WORDS[i+1]//\"/} ;;
                # an instance is either preferred or available, never both
                -preferred|-available)
                    [[ $prev == -preferred || $prev == -available ]] && skip+=,${COMP_WORDS[i+1]//\"/} ;;
            esac
        done

        # enum values of this option known from another verb of the same object
        # (e.g. "add pdb -role {PRIMARY | ...}" but "modify pdb -role <role>")
        if [[ -z ${_SRVCTL_ENUM[$key:$prev]+x} ]]; then
            for k in "${!_SRVCTL_ENUM[@]}"; do
                # shellcheck disable=SC2004  # associative array key, not arithmetic
                [[ $k == *:"$obj:$prev" ]] && { _SRVCTL_ENUM[$key:$prev]=${_SRVCTL_ENUM[$k]}; break; }
            done
        fi

        # comma separated lists: complete the part after the last comma
        local quote="" prefix="" word=$cur
        [[ $word == \"* ]] && { quote='"'; word=${word#\"}; }
        if [[ $word == *,* ]]; then
            prefix=${word%,*},; word=${word##*,}
        fi

        if [[ -n ${_SRVCTL_ENUM[$key:$prev]+x} ]]; then
            vals=${_SRVCTL_ENUM[$key:$prev]}
        else
            case $prev:$ph in
                # files first: "srvctl import gns -instance <filename>"
                -oraclehome:*|*:oracle_home) ;;
                *:*file*|*:*path*)           # spfile, pwfile, statefile, exportfile, path ...
                    compopt -o filenames 2>/dev/null
                    mapfile -t COMPREPLY < <(compgen -f -- "$cur")
                    return 0 ;;
            esac
            case $prev:$ph in
                -db:*|*:db_unique_name)      vals=$(_srvctl_comp_res db) ;;
                -service:*|-services:*)      vals=$(_srvctl_comp_res svc "$db") ;;
                -pdb:*)                      vals=$(_srvctl_comp_res pdb "$db") ;;
                -listener:*)
                    # scan_listener: only "add -listener <prefix>" => new name, nothing to offer
                    [[ $obj == scan_listener ]] && return 0
                    vals=$(_srvctl_comp_res lsnr) ;;
                -diskgroup:*)                vals=$(_srvctl_comp_res dg) ;;
                # instances of the database (and of the node, if -node was given)
                -instance:*|-instances:*|-preferred:*|-available:*|-targetinstance:*|-oldinst:*)
                                             vals=$(_srvctl_comp_res inst "$db" "$node") ;;
                -node:*|-nodes:*|-currentnode:*|-targetnode:*|-homenode:*|-srcnode:*|-addnode:*|-deletenode:*|-server:*|-servers:*|*:node_name*)
                                             vals=$(_srvctl_comp_nodes) ;;
                # cluster only (these options do not exist in the Restart help)
                -netnum:*|-defaultnetnum:*)  vals=$(_srvctl_comp_res net) ;;
                -vip:*)                      vals=$(_srvctl_comp_res vip "" "$node") ;;
                -scannumber:*)               vals=$(_srvctl_comp_res scan) ;;
                -scanname:*)                 vals=$(_srvctl_comp_res scanname) ;;
                -volume:*)                   vals=$(_srvctl_comp_res vol) ;;
                -device:*)                   vals=$(_srvctl_comp_res dev) ;;
                # values only documented in the option description, not in the usage line
                -stopoption:*)
                    if [[ $obj == service ]]; then vals="NONE IMMEDIATE TRANSACTIONAL"
                    else vals="NORMAL TRANSACTIONAL IMMEDIATE ABORT"; fi ;;
                -startoption:*)              vals="OPEN MOUNT NOMOUNT" ;;
                -oraclehome:*|*:oracle_home)
                    # homes from the central inventory; plain directories only once typing started
                    mapfile -t COMPREPLY < <(compgen -W "$(_srvctl_comp_homes)" -- "$cur")
                    if (( ${#COMPREPLY[@]} == 0 )) && [[ -n $cur ]]; then
                        compopt -o filenames 2>/dev/null
                        mapfile -t COMPREPLY < <(compgen -d -- "$cur")
                    fi
                    return 0 ;;
                *)  return 0 ;;   # free text (timeouts, names to be created ...)
            esac
        fi
        while IFS= read -r w; do
            [[ -z $w || ,$prefix$skip, == *,"$w",* ]] && continue   # skip entries already listed
            COMPREPLY+=("$quote$prefix$w")
        done < <(compgen -W "$vals" -- "$word")
        [[ -n $prefix ]] && compopt -o nospace 2>/dev/null
        return 0
    fi

    # options not yet used on the command line
    local -A used=()
    for (( i = 3; i < COMP_CWORD; i++ )); do
        [[ ${COMP_WORDS[i]} == -* ]] && used[${COMP_WORDS[i]}]=1
    done
    for w in ${_SRVCTL_OPTS[$key]} -help; do
        [[ -z ${used[$w]} ]] && vals+=" $w"
    done
    mapfile -t COMPREPLY < <(compgen -W "$vals" -- "$cur")
    return 0
}

complete -F _srvctl_complete srvctl
