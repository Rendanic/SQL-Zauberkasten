# SQL-Zauberkasten ("SQL magic box")

The SQL-Zauberkasten is a collection of scripts for Oracle databases: more than 380 SQL\*Plus scripts for day-to-day DBA work, plus a few helper tools around them.

## Table of contents

- [What is in the box](#what-is-in-the-box)
- [Finding a script](#finding-a-script)
- [Getting started](#getting-started)
- [Using the Zauberkasten on hosts without Oracle (nix-shell)](#using-the-zauberkasten-on-hosts-without-oracle-nix-shell)
  - [Keeping SQLcl up to date (Renovate)](#keeping-sqlcl-up-to-date-renovate)
- [Enterprise Edition and licensing](#enterprise-edition-and-licensing)
- [Development](#development)
  - [pre-commit](#pre-commit)
- [Contributing](#contributing)

## What is in the box

| Directory | Content |
|---|---|
| `sql/` | The scripts themselves, grouped by topic. `table` holds everything about tables, `session` everything about sessions, and so on. |
| `sql/ee/` | Scripts that use Enterprise Edition features (see [licensing](#enterprise-edition-and-licensing)). |
| `asm/` | `kfod_disks.sh` shows the details of ASM disks for a given disk string. |
| `amon/` | amon, a console monitor for Oracle databases, for 10.2, 11.2 and 19c (Oracle Linux 7/8/9 and Ubuntu 22.04). `amon/amon.sh` starts the 19c binary that matches the operating system and passes all parameters on. `amon/docker` contains a Dockerfile (OL9 based) to run it as a container. |
| `snapper/` | Scripts to download Tanel Poder's Session Snapper. |
| `getMOSPatch/` | Git submodule [MarisElsins/getMOSPatch](https://github.com/MarisElsins/getMOSPatch), downloads patches from My Oracle Support. |
| `rlwrap/` | Everything about rlwrap: the filter for the tab completion of `@script` in `sq.sh` (see `rlwrap/README.md`) and the choice of the rlwrap binary. The installed rlwrap is used (`dnf install rlwrap`); the old prebuilt 0.32 binaries (they crashed on current systems) are gone, they are still in the Git history. |

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
| `sq.sh` | Starts `rlwrap sqlplus / as sysdba` (or `/ as sysasm` when the SID starts with `+`). It uses the `rlwrap` from your `PATH` (or the one in `ZK_RLWRAP`) and falls back to plain sqlplus with a hint when there is none. Set `ZK_NORLWRAP=1` to skip rlwrap. With rlwrap, Tab behind `@`, `@@` and `start` completes the scripts in the directory tree of `SQLPATH` (see `rlwrap/README.md`, `ZK_NOCOMPLETE=1` switches it off). Without a database environment it uses SQLcl instead (see the nix-shell chapter). Any parameters are passed on to sqlplus. |
| `sqzk.sh` | Wrapper for `sq.sh` that sets `SQLPATH` to the `sql` directory of the Zauberkasten, so all scripts can be called without a path. |
| `rman.sh` | Same idea as `sq.sh`, for RMAN. |
| `rlwrap.sh` | Starts the rlwrap that the scripts would use. |
| `zk_lib.sh` | Common functions of the scripts above (sourced, not started directly). |
| `amon.sh` | Starts amon in the right version for your platform. |

Typical session:

```bash
export ORACLE_HOME=... ORACLE_SID=...
/path/to/SQL-Zauberkasten/sql/sqzk.sh
```

## Using the Zauberkasten on hosts without Oracle (nix-shell)

`sq.sh`, `sqzk.sh` and `rman.sh` normally need a local Oracle installation (`ORACLE_HOME`). On a workstation or jump host without Oracle, the `shell.nix` in the repository root provides SQLcl, so `sq.sh` and `sqzk.sh` can run the scripts against a remote database.

### What the shell provides

- [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/) (downloaded and unpacked by Nix, no Oracle account needed on your side), available as `sql`. The path is also exported as `SQLCL_BIN`.
- JDK 21, which SQLcl needs
- [go-task](https://taskfile.dev), [Renovate](https://docs.renovatebot.com/), `jq`, `pre-commit` and `tig`

### Usage

Install [Nix](https://nixos.org/download/), then start the shell in the repository root:

```bash
nix-shell
```

With [direnv](https://direnv.net/) and nix-direnv, the included `.envrc` loads the shell automatically when you enter the directory (run `direnv allow` once).

`sq.sh` and `sqzk.sh` also work in the nix-shell. If `ORACLE_HOME` is not set (or contains no `sqlplus`), they start SQLcl instead of sqlplus, with the same parameters and with rlwrap if it is installed. `sqzk.sh` sets `SQLPATH`, so all scripts can be called without a path:

```bash
nix-shell
./sql/sqzk.sh                         # starts SQLcl unconnected
SQL> connect system@//dbhost:1521/pdb1
SQL> @session/gsi11

./sql/sqzk.sh system@//dbhost:1521/pdb1   # or connect directly
```

SQLcl is taken from `SQLCL_BIN` (set by the nix-shell) or from `sql` in the `PATH`. Set `ZK_CLIENT=sqlplus` or `ZK_CLIENT=sqlcl` to force one of them.

Notes:

- Without parameters SQLcl cannot use operating system authentication (`/ as sysdba`), so it starts unconnected. That login only works on the database host itself. Connect with a user that has the required privileges instead.
- `rman.sh` needs a local Oracle installation and has no SQLcl fallback.
- The first start downloads SQLcl and needs network access.

### Keeping SQLcl up to date (Renovate)

The SQLcl version is set in `shell.nix` (`sqlclVersion`). [Renovate](https://docs.renovatebot.com/) keeps it current: `renovate.json` defines a custom datasource that reads the latest version from the Homebrew cask API (`https://formulae.brew.sh/api/cask/sqlcl.json`), because Oracle offers no machine-readable version feed. When a new release appears, Renovate opens a pull request that changes `sqlclVersion`. This requires the Renovate GitHub app to be enabled for the repository.

`shell.nix` downloads SQLcl with `builtins.fetchTarball` and no hash, so the pull request needs no hash update. The drawback is that the download is not pinned and not verified.

Renovate also keeps `sql/ocenv` current. The file comes from [opitzconsulting/oracle-scripts](https://github.com/opitzconsulting/oracle-scripts/blob/main/ocenv). `tools/renovate/ocenv.version` records the upstream version (the committer date of the last upstream commit), the commit and the git blob of `sql/ocenv`. A custom datasource reads the commits of `ocenv` from the GitHub API. When there is a new commit, Renovate runs `tools/renovate/ocenv_update.sh` as a post-upgrade task, which replaces `sql/ocenv` and updates `ocenv.version`. This only works on a Renovate that allows this command (`RENOVATE_ALLOWED_COMMANDS`, i.e. self-hosted).

You can run Renovate locally with go-task inside the nix-shell:

| Task | Purpose |
|---|---|
| `task renovate:check` | Validates `renovate.json` (strict). |
| `task renovate:ocenv` | Checks that `sql/ocenv` still matches the upstream version recorded in `tools/renovate/ocenv.version`. |
| `task renovate:report` | Dry run: runs Renovate locally and prints the available updates, e.g. `shell.nix: sqlcl 26.1.0.086.1709 -> 26.3.1.301.1413`. Needs network access, creates no pull requests, and writes `renovate-report.json` (git-ignored). |

## Enterprise Edition and licensing

The tree `sql/ee` contains scripts that use options available only in Enterprise Edition. You need the matching licenses. The scripts do not check whether you have them.

| Directory | Requirement |
|---|---|
| `ee/diag` | Diagnostic Pack (ASH, AWR) |
| `ee/tuning` | Diagnostic and Tuning Pack |
| `ee/index` | no extra license, but Enterprise Edition only |

There is no warranty.

## Development

### pre-commit

The repository uses [pre-commit](https://pre-commit.com/) to check every commit. The hooks are defined in `.pre-commit-config.yaml`:

| Hook | Purpose |
|---|---|
| `trailing-whitespace`, `end-of-file-fixer` | Clean whitespace and file endings (they fix the files themselves, so the first commit fails and you commit again). |
| `check-merge-conflict` | Leftover merge markers. |
| `detect-private-key`, `forbid-new-submodules` | No private keys, no new submodules. |
| `check-executables-have-shebangs` | Executable files need a shebang. |
| `shellcheck` | Lints all shell scripts. |
| `shfmt` | Checks the shell style (2 spaces, `-i 2 -ci`). |

The hooks need `shellcheck`, so work inside the `nix-shell` (see above). It provides `pre-commit`, `shellcheck` and `shfmt`:

```bash
nix-shell
pre-commit install            # once per clone: run the hooks on every git commit
pre-commit run --all-files    # check the whole repository, e.g. before a pull request
pre-commit run --files sql/sq.sh   # check single files
pre-commit autoupdate         # update the hook versions
```

Commit from inside the nix-shell as well. Outside of it the `shellcheck` hook cannot find its tool. With direnv the shell is loaded automatically.

To fix a `shfmt` finding, format the file with `shfmt -w -i 2 -ci <file>` (it is part of the nix-shell).

## Contributing

New scripts are accepted by pull request only if they can be redistributed under the GPL.

Regards,
Thorsten Bruhns
