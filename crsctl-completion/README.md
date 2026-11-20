# crsctl bash completion

Bash completion for Oracle `crsctl` (Oracle Restart and Grid Infrastructure cluster).
The commands are parsed from the help of the crsctl that is called, so the completion follows its version.
Tested with 26ai, see [Tested](#tested).

## Installation

```bash
# per user
echo 'source ~/crsctl-completion/crsctl_completion.bash' >> ~/.bashrc

# system-wide (any bash, with or without the bash-completion package)
cp crsctl_completion.bash /etc/bash_completion.d/crsctl     # if bash-completion is installed
# otherwise: cp to /etc/profile.d/crsctl_completion.sh
```

`crsctl` is mostly used by `root`, `grid` or `oracle`. The completion works for all of them. For `root`
it must be sourced in root's `.bashrc` (or system-wide) and `crsctl` must be in root's `PATH` or typed with its full path.

## What gets completed

| Position / option | Source |
|---|---|
| command, object, further words (`crsctl get cluster mode config`) | parsed from `crsctl help`, `crsctl <command> -h` and `crsctl {status\|add\|modify} <object> -h` of the crsctl being called |
| abbreviations (`crsctl stat res -t`) | resolved like crsctl does, first match in the order of the help |
| options already used | are not offered again |
| `{A \| B}` values, keywords (`crsctl set crs drain enable true`) | parsed from the usage lines |
| `-init` | added for `status`, `start` and `stop resource`: not in the help, but needed all the time |
| resource names | `crsctl status resource` (`-init` on the command line: `crsctl status resource -init`) |
| types, servers, server pools, resource groups, categories | `crsctl status type\|server\|serverpool\|resourcegroup\|category` |
| disk groups (`crsctl set css votedisk asm`, `crsctl replace votedisk +DG`) | names of the `ora.<dg>.dg` resources |
| `-attr` | attributes of the resources named on the command line, of the `-type`, or of all resources |
| `-attr "NAME=value,..."` | attribute names (`NAME=`), no values |
| `-w` filter (inside the quotes) | attribute names, operators (`co`, `st`, `eqi` ...), `AND`/`OR`, types after `TYPE =`, `ONLINE`/`OFFLINE`/`INTERMEDIATE` after `STATE =`, `ONLINE`/`OFFLINE` after `TARGET =` |
| `crsctl get\|set log <daemon>`, `crsctl set log res` | debug modules from `crsctl lsmodules <daemon>`, resource names; levels `0` to `5` after `=` |
| `crsctl get\|set\|unset css <parameter>` | built-in list: `disktimeout misscount priority reboottime` |
| `-u`, `-g`, `-o` (permissions) | users and groups of the operating system |
| `...file...`, `...path...` | filenames |

Names of new objects (`crsctl add resource <name>`) are not completed on purpose.
Comma separated lists are supported (`-attr NAME,TY<TAB>`), as well as values behind `=`
(`crsctl set log css CSSD=<TAB>` offers the levels), quoted or not.

## Oracle Restart vs. GI cluster

crsctl itself shows only the commands that exist in its mode, and the completion follows the help:

- Oracle Restart: `crsctl check has`, `crsctl start|stop has`, `crsctl config|enable|disable has`.
- GI cluster: `crsctl check crs|cluster`, `crsctl start|stop crs|cluster`, `crsctl query crs ...`, `crsctl config|enable|disable crs`,
  `-n <server>` with the cluster nodes, server pools, policies and categories.

The mode is read from `/etc/oracle/ocr.loc` (`local_only=TRUE` → Oracle Restart, otherwise GI cluster).
It is part of the name of the cache file, so a `$HOME` shared between hosts or a conversion
of a server does not mix up the commands.

- **Servers**: `crsctl status server`. If the stack is down: GI cluster → `olsnodes`, then `NODE_NAME_LIST` in
  `<GI_HOME>/crs/install/crsconfig_params` (does not include nodes added later); Oracle Restart → `hostname -s`.
- **GI home**: the home of the `crsctl` that is called, fallback `$ORACLE_HOME/bin/crsctl`, then `crs_home` in
  `/etc/oracle/olr.loc`. `/etc/oratab` is not used.
- With the stack down all values read from the clusterware are empty. Commands, options and enum values
  come from the static help and still work.

## Caches

- Parsed help: `${XDG_CACHE_HOME:-~/.cache}/crsctl-completion/<path-of-crsctl>.<restart|cluster>.bash`
  (override with `CRSCTL_COMP_CACHE`). It is built on the first TAB (about 1 s) and rebuilt
  automatically when the crsctl binary is newer (patching / new home).
- crsctl output: kept in the shell for `CRSCTL_COMP_TTL` seconds (default 10).

To build the cache, `crsctl <command> -h` is run for every command and
`crsctl <command> <object> -h` only for `status`, `add` and `modify`. The other commands (`stop`, `start`,
`relocate`, `delete` ...) have complete usage lines in the command help, and an object help is
not requested for commands that act on the stack.

## Limits

- `crsctl lsmodules` (debug modules) needs `root` in a GI cluster. For other users `get|set log` offers no modules.
  In Oracle Restart, `lsmodules` works for the Grid Infrastructure owner, but only for the daemons that exist there (`css`, `evm`).
- Inside quotes bash closes the quote after a unique completion, also behind `NAME=` in `-attr "NAME="`
  and `set log css "CSSD="`. Move the cursor one position to the left to continue, or leave the quotes out.
- The list of CSS parameters is static: it contains the parameters that `crsctl get css` accepts.
- Resources of a resource group are listed by crsctl as `name(group)`. The completion offers the name only,
  because the form with the group is rejected by crsctl (`CRS-4037`).

## Tested

The completion is tested with [oravirt/ansible-oracle](https://github.com/oravirt/ansible-oracle)
molecule scenarios, the primary test platform for this project. Focus is on 26ai.

- **Oracle Restart 26ai** (molecule `has-ol9`, GI 26.04) as `oracle`: all commands and objects,
  resources, types, servers, disk groups, attributes, `-w` filters, debug modules, `-init`, abbreviations.
- **GI cluster 26ai**, 2 nodes (molecule `rac`, GI 26.04) as `grid` and as `root`: cluster commands,
  `-n` with cluster nodes, server pools, categories, `-init` resources, resource group names, `lsmodules` as `root`.
- Interactive tests with a real TAB (bash 5.1): unique and ambiguous completions, quoted `-w` filters,
  `=` as word break, abbreviations, commands behind `&&`.
- The generated data is identical with `gawk` and `mawk`. `shellcheck` and `shfmt -i 2 -ci` report nothing.
- **Not tested**: 19c, a GI cluster with the stack down, all commands as `root`.
