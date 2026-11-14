# SQL-Zauberkasten ("SQL magic box")

The SQL-Zauberkasten is a collection of scripts for Oracle databases: more than 380 SQL\*Plus scripts for day-to-day DBA work, plus a few helper tools around them.

## Table of contents

- [What is in the box](#what-is-in-the-box)
- [Finding a script](#finding-a-script)
- [Getting started](#getting-started)
- [Using the Zauberkasten on hosts without Oracle (nix-shell)](#using-the-zauberkasten-on-hosts-without-oracle-nix-shell)
- [Enterprise Edition and licensing](#enterprise-edition-and-licensing)
- [Contributing](#contributing)

## What is in the box

| Directory | Content |
|---|---|
| `sql/` | The scripts themselves, grouped by topic. `table` holds everything about tables, `session` everything about sessions, and so on. |
| `sql/ee/` | Scripts that use Enterprise Edition features (see [licensing](#enterprise-edition-and-licensing)). |
| `asm/` | `kfod_disks.sh` shows the details of ASM disks for a given disk string. |
| `amon/` | amon, a console monitor for Oracle databases, for 10.2, 11.2 and 19c (Oracle Linux 7/8/9 and Ubuntu 22.04). `amon/docker` contains a Dockerfile (OL9 based) to run it as a container. |
| `snapper/` | Scripts to download Tanel Poder's Session Snapper. |
| `getMOSPatch/` | Git submodule [MarisElsins/getMOSPatch](https://github.com/MarisElsins/getMOSPatch), downloads patches from My Oracle Support. |
| `rlwrap/` | Prebuilt rlwrap binaries (Linux 32/64 bit, SPARC) for a readline history in SQL\*Plus and RMAN. |

Topics in `sql/` include:

- sessions, SGA, buffer cache, statistics (DBMS_STATS)
- tables, indexes, LOBs, materialized views, objects
- tablespaces, datafiles, temp, undo
- users and privileges, audit, parameters, traces (e.g. 10053)
- RMAN, recovery, ASM, Data Pump, PDBs, Scheduler, APEX
- Statspack, server alerts, explain plans (`xplan`)

`sql/directory_description.txt` describes every directory.

## Finding a script

Every directory contains a file named `_scriptinfo.txt` with a one-line description for each script. Grep it to find what you need:

```bash
grep -ri 'tablespace' sql/*/_scriptinfo.txt
```

## Getting started

The `.sh` scripts in `sql/` make everyday use easier:

| Script | Purpose |
|---|---|
| `sq.sh` | Starts `rlwrap sqlplus / as sysdba` (or `/ as sysasm` when the SID starts with `+`). It picks the right rlwrap automatically, so it works on 32 and 64 bit Linux. Any parameters are passed on to sqlplus. |
| `sqzk.sh` | Wrapper for `sq.sh` that sets `SQLPATH` to the `sql` directory of the Zauberkasten, so all scripts can be called without a path. |
| `rman.sh` | Same idea as `sq.sh`, for RMAN. |
| `rlwrap.sh` | Starts the matching rlwrap version for your platform. |
| `amon.sh` | Starts amon in the right version for your platform. |

Typical session:

```bash
export ORACLE_HOME=... ORACLE_SID=...
/path/to/SQL-Zauberkasten/sql/sqzk.sh
```

## Using the Zauberkasten on hosts without Oracle (nix-shell)

`sq.sh`, `sqzk.sh` and `rman.sh` need a local Oracle installation (`ORACLE_HOME`). On a workstation or jump host without Oracle, the `shell.nix` in the repository root provides everything needed to run the scripts against a remote database.

### What the shell provides

- [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) (downloaded and unpacked by Nix, no Oracle account needed on your side), available as `sql`. The path is also exported as `SQLCL_BIN`.
- JDK 21, which SQLcl needs
- [go-task](https://taskfile.dev), `pre-commit` and `tig`

### Usage

Install [Nix](https://nixos.org/download/), then start the shell in the repository root:

```bash
nix-shell
```

With [direnv](https://direnv.net/) and nix-direnv, the included `.envrc` loads the shell automatically when you enter the directory (run `direnv allow` once).

Connect to a remote database and run scripts from the Zauberkasten. SQLcl reads `SQLPATH` like SQL\*Plus does, so the scripts can be called without a path:

```bash
export SQLPATH=$PWD/sql
sql system@//dbhost:1521/pdb1
SQL> @session/gsi11
```

Notes:

- The scripts that need `SYSDBA` operating system authentication (`/ as sysdba`) only work on the database host itself. Connect with a user that has the required privileges instead.
- `rman.sh`, `rlwrap.sh` and the other helpers in `sql/` are meant for hosts with an Oracle installation and are not part of this workflow.
- The first start downloads SQLcl and needs network access.

## Enterprise Edition and licensing

The tree `sql/ee` contains scripts that use options available only in Enterprise Edition. You need the matching licenses. The scripts do not check whether you have them.

| Directory | Requirement |
|---|---|
| `ee/diag` | Diagnostic Pack (ASH, AWR) |
| `ee/tuning` | Diagnostic and Tuning Pack |
| `ee/index` | no extra license, but Enterprise Edition only |

There is no warranty.

## Contributing

New scripts are accepted by pull request only if they can be redistributed under the GPL.

Regards,
Thorsten Bruhns
