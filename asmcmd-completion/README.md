# asmcmd bash completion

Bash completion for Oracle `asmcmd` (Oracle Restart and Grid Infrastructure cluster).
The commands are parsed from the help of the asmcmd that is called, so the completion follows its version.
Tested with 26ai, see [Tested](#tested).

## Installation

```bash
# per user
echo 'source ~/asmcmd-completion/asmcmd_completion.bash' >> ~/.bashrc

# system-wide (any bash, with or without the bash-completion package)
cp asmcmd_completion.bash /etc/bash_completion.d/asmcmd     # if bash-completion is installed
# otherwise: cp to /etc/profile.d/asmcmd_completion.sh
```

asmcmd connects to the ASM instance given by `ORACLE_HOME` and `ORACLE_SID` of your shell, and the user must be a member of
the OSASM group (usually `grid`, or `oracle` in Oracle Restart). The completion calls asmcmd with the same environment,
so it sees exactly what your asmcmd sees.

## What gets completed

| Position / option | Source |
|---|---|
| command (`asmcmd <TAB>`) | the `commands:` list of `asmcmd help` |
| global options (`-V`, `--privilege`, `-v`, `--inst` ...) and their values | the synopsis of `asmcmd help` |
| options of a command, values like `--redundancy {high\|mirror\|unprotected}` | the synopsis of `asmcmd help <command>`, read the first time the command is completed |
| options already used | are not offered again |
| `asmcmd help <command>` | the command list |
| disk groups (`-G`, `mount`, `lsdg`, `chkdg`, `dropdg`, `rebal` ...) | `crsctl status resource` of the home of asmcmd, fallback `asmcmd lsdg` |
| `asmcmd mount DATA,FRA` (comma separated lists) | disk groups, entries that are already in the list are not offered again |
| ASM paths and aliases of `ls`, `cd`, `du`, `find`, `stat`, `rm`, `rmalias`, `mkdir`, `mkalias`, `chmod`, `chown`, `chgrp`, `mvfile` ... | `asmcmd ls <directory>`, see below |
| files of `cp`, `md_backup`, `md_restore`, `spcopy`, `spbackup`, `spmove`, `pwcopy`, `pwmove`, `pwset`, `kscopy`, `-S <script>` ... | a word that starts with `+` is an ASM path, anything else is a file name of the file system |
| `setattr -G <diskgroup> <attribute>` | `asmcmd lsattr -G <diskgroup>` |

## ASM paths

- A path with or without `+` is completed (`+DATA/DB<TAB>`, `DATA/DB<TAB>`): without `+` the path is relative to the root of ASM,
  as for asmcmd. `cd`, `du` and `mkdir` offer directories only.
- Directories end with `/` and no space is added, so you can go on with the next level.
- ASM names are not case sensitive, so `+data/dbh<TAB>` finds `DBHAS/` and keeps what you typed in front of it.
- Special characters are escaped by bash as for file names (`PDB$SEED/` becomes `PDB\$SEED/`).
- Every directory level is one `asmcmd ls` call. asmcmd is a Perl script and needs about a second per call.
  The result is kept for `ASMCMD_COMP_TTL` seconds (default 10), so a second TAB on the same level answers immediately.
  The first TAB for a command also reads `asmcmd help <command>` once (about 0.7 s).

## Oracle Restart vs. GI cluster

asmcmd offers the same commands in both. What differs is the environment of your shell:

- Oracle Restart: `ORACLE_HOME` is the Grid Infrastructure home, `ORACLE_SID=+ASM`.
- GI cluster: `ORACLE_SID=+ASM1`, `+ASM2` ... on the node. With Flex ASM asmcmd connects to any ASM instance, `--inst` selects one.

The disk groups come from the home that contains the asmcmd that is called (`<home>/bin/crsctl`). `/etc/oratab` is not used.

## Caches

- Parsed help: `${XDG_CACHE_HOME:-~/.cache}/asmcmd-completion/<path-of-asmcmd>.top.bash` and `...cmd_<command>.bash`
  (override with `ASMCMD_COMP_CACHE`). The files are rebuilt automatically when asmcmd is newer (patching / new home).
- Output of asmcmd and crsctl: kept in the shell for `ASMCMD_COMP_TTL` seconds (default 10).

## Limits

- Only the one-shot form `asmcmd <command> ...` is completed, not the commands that you type at the `ASMCMD>` prompt of an interactive asmcmd.
- Not completed: users, user groups, templates, file groups, quota groups, volumes, disks and failure groups (`-D`, `-F`), database and
  instance names, the types of `find --type`. For these the options of the command are offered instead.
- `lsattr`, `lsdsk` and other commands with a `<pattern>` of names offer no values for the pattern.
- Inside quotes bash closes the quote after a unique completion, also behind a directory (`'+DATA/DBHAS/'`). Move the cursor one
  position to the left to go on, or leave the quotes out: they are not needed, bash escapes special characters.
- With ASM down, or without the right to connect, no paths, disk groups from `asmcmd lsdg` or attributes are offered.

## Tested

The completion is tested with [oravirt/ansible-oracle](https://github.com/oravirt/ansible-oracle)
molecule scenarios, the primary test platform for this project. Focus is on 26ai.

- **Oracle Restart 26ai** (molecule `has-ol9`, GI 26.04, `ORACLE_SID=+ASM`) as `oracle`: all commands and global options,
  disk groups, paths of `+DATA` (directories, files, case, with and without `+`), `cp` with ASM and file system paths, comma lists, attributes.
- **GI cluster 26ai**, 2 nodes (molecule `rac`, GI 26.04, `ORACLE_SID=+ASM1`) as `grid`: disk groups (including the
  `name(group)` form of crsctl), paths of `+DATA` and `+CRS`, global options.
- Interactive tests with a real TAB (bash 5.1) in both: unique and ambiguous completions, no space behind `/`, commands behind `&&`,
  quotes, `\` escapes. Names with `$`, a space and an apostrophe were tested with a script in place of asmcmd, which lists such names.
- The parsed help of all 116 commands is identical with `gawk` and `mawk`. `shellcheck` and `shfmt -i 2 -ci` report nothing.
- **Not tested**: 19c, asmcmd as `root`, Flex ASM with a remote instance, ASM down, dismounted disk groups.
