# rlwrap in the SQL-Zauberkasten

`sq.sh` (and `sqzk.sh`) start sqlplus below [rlwrap](https://github.com/hanslub42/rlwrap), for a command history and
line editing. This directory holds the rest that belongs to it: a filter for the **tab completion of `@script`** and the
choice of the rlwrap binary.

## Tab completion of `@script`

Tab behind `@`, `@@` or `start` walks through the directory tree of the scripts, one level at a time, without `.sql`:

```
SQL> @sess<TAB>            ->  @session/
SQL> @session/swu<TAB>     ->  @session/swuser
SQL> @session/sw<TAB><TAB>     lists swall  swuser ...
```

- The scripts are searched where sqlplus finds them: in the working directory and in the directories of `SQLPATH`
  (`sqzk.sh` sets `SQLPATH` to the `sql` directory of the Zauberkasten). Several directories are merged.
- Directories end with `/` and no space is added, scripts get a space (the parameters follow).
- Upper and lower case of the name are not distinguished (`@tbs/TBSINF<TAB>` gives `@tbs/tbsinfo`). Names that start with `_` or `.`
  (for example `_scriptinfo.txt`) only show up when you type the first character.
- Directories of the `SQLPATH` directories are all offered. In the working directory only the directories that contain `.sql` files
  (up to three levels down) are, so a `$HOME` full of other directories does not clutter the list.
- Everywhere else Tab completes **file names**: `spool /tm<TAB>`, `host ls /u0<TAB>`, `prompt ...`. rlwrap asks the filter for completions
  only in its file name mode, so `sq.sh` starts it with `-c` (and with `-e ''`, so nothing is added behind a completion; the filter adds the
  space behind a script name). Before there was no completion at all. Words of SQL statements are not completed.
- `startup` does not start a script.

### Description and parameters: Alt-h

Alt-h shows what the script on the line is about, in the line below the prompt:

```
SQL> @session/swuser 5      (press Alt-h)
session/swuser: Sessions for a connected user | 1: DB_USERNAME | 2: SQL_ID
```

The description is the one in the `_scriptinfo.txt` of the directory of the script. The parameters are the `-- Parameter N:` lines in the
header of the script (next section). A longer text is cut to the width of the terminal.

The key is bound in `zk_inputrc`. rlwrap reads it instead of your `~/.inputrc`, which is included first (`/etc/inputrc` as well),
so your own settings stay. If you set `INPUTRC` yourself it is kept and there is no Alt-h: add this line to your file to get it:

```
"\eh": rlwrap-hotkey-without-history
```

### Layout of the parameters in a script

One line per parameter in the header of the script. Only this layout is read, spelled exactly like this:

```
-- Parameter 1: DB_USERNAME
-- Parameter 2: SQL_ID
```

Two dashes, one blank, `Parameter`, the number, a colon. The text behind the colon is free. Other spellings (`prompt Parameter 1:`, `-- Parameter 1.`,
`-- parameter 1:` ...) are ignored for now: scripts that use them are shown without parameters. The completion of the names works for all scripts.

`tools/check_script_params.py` shows which scripts still have to be adapted. It changes nothing:

```bash
python3 tools/check_script_params.py          # with the names of the scripts
python3 tools/check_script_params.py --quiet  # only the numbers
```

It lists the scripts that use `&1`, `&2` ... without `-- Parameter N:` lines, whose numbering is not 1, 2, 3 ..., that use a higher `&N`
than there are lines, and that are missing in the `_scriptinfo.txt` of their directory.

### Requirements

The completion is switched on by `sq.sh` when everything is there. If something is missing, rlwrap starts as before and says nothing:

- `python3` (3.6 or newer, only the standard library is used)
- an rlwrap that comes with its Python filter library `rlwrapfilter.py`. It is looked for next to the rlwrap that is used
  (`<prefix>/share/rlwrap/filters`, usually `/usr/share/rlwrap/filters`), because the library has to fit the version of rlwrap.
  rlwrap 0.47 and 0.48 have it.

`rman.sh` does not use the filter (the completion is for `@script`).

## Which rlwrap is used

`zk_find_rlwrap` in `sql/zk_lib.sh` takes the first one it finds:

1. `ZK_RLWRAP`, if you set it (full path of an rlwrap binary)
2. **`rlwrap` from your `PATH`.** An installed rlwrap always wins (`dnf install rlwrap`).
3. A bundled static rlwrap in `rlwrap/static/<uname -m>/rlwrap`, only if there is none installed, and only if it is executable and
   `--version` works. There is no such binary in the repository at the moment, so this step does nothing yet.
4. None: `sq.sh` starts without rlwrap and tells you so.

The old prebuilt rlwrap 0.32 binaries that used to be in this directory are removed (they crashed on current systems). They are still in the Git history.

## Variables

| Variable | Meaning |
|---|---|
| `ZK_RLWRAP` | full path of the rlwrap binary to use |
| `ZK_NORLWRAP=1` | no rlwrap at all (no history, no completion) |
| `ZK_NOCOMPLETE=1` | rlwrap, but without the filter (no completion of `@script`, no Alt-h) |
| `ZK_RLWRAP_OPT` | options for rlwrap, default `-w 200 -i` (the options of the filter, `-c -z zk_filter.py -e ''`, are added to them) |
| `ZK_FILTER_DEBUG=<file>` | the filter writes every completion and hotkey call (what it got and what it answered) to this file, to see why something does not work |
| `INPUTRC` | your own readline file; if set it is used as it is (see Alt-h) |

`sq.sh` also sets `ZK_COMPLETE_SQL=1` and the filter setup sets `RLWRAP_FILTERDIR` (our directory, rlwrap looks for the filter there) and
`ZK_FILTERLIB` (the library of the installed rlwrap) for the programs it starts. You do not need to set these.

## Files

| File | Purpose |
|---|---|
| `zk_filter.py` | the rlwrap filter: completion and Alt-h |
| `zk_scriptdoc.py` | reads the parameters and the description of a script (also used by `tools/check_script_params.py`) |
| `zk_inputrc` | binds Alt-h to the filter and includes your own readline files |
| `zk_completion.sh` | sourced by `sql/zk_lib.sh`: finds the filter library and sets up the options |
| `test_zk_filter.py` | unit tests of the filter and the parser: `python3 -m unittest rlwrap/test_zk_filter.py` |
| `test_zk_lib.sh` | tests of the choice of the rlwrap binary and of the filter setup, with stand-ins for rlwrap: `bash rlwrap/test_zk_lib.sh` |

## Limits

- Only `.sql` files are offered. A name with a dot in it (`a.b.sql`) is completed up to the dot and after it.
- The description of Alt-h is one line. Many or long parameters are cut at the width of the terminal.
- The completion is for the SQL client of `sq.sh` (sqlplus and SQLcl). It does not know what a script does with its parameters.
- Names of directories have to be typed in the right case (the file system is case sensitive and so is sqlplus), only the last
  part of the name is matched without regard to case.
- The names of the parameter values (users, owners ...) are not completed, only described.

## Tested

- **sqlplus 19.33 with rlwrap 0.47** (Oracle Linux 9, python 3.9) through `sq.sh`: `@`, `@@` and `start`, one level at a time, no space behind a
  directory and one behind a script, a completed script is really started, Alt-h shows description and parameters, a script without parameters shows only
  the description, SQL text is not touched, file names behind `prompt`.
- **rlwrap 0.48** (nix) with `cat` as client: the same completions and Alt-h.
- `ZK_NOCOMPLETE=1`, and a `PATH` without `python3`: rlwrap runs without the filter. `rman.sh`: no filter.
- The unit tests (`test_zk_filter.py`) and `test_zk_lib.sh`; `shellcheck -x` and `shfmt -i 2 -ci` are clean.
- **Not tested**: rlwrap older than 0.47, Python 3.6 (the code uses nothing newer, but it was run with 3.9 and 3.12), SQLcl, a static rlwrap
  (there is none in the repository yet, step 3 of the choice is only tested with a stand-in).
