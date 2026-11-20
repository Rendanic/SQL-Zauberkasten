#!/usr/bin/env python3
"""rlwrap filter of the SQL-Zauberkasten: tab completion for @script in sqlplus.

Started by sq.sh through rlwrap (rlwrap -z), see rlwrap/README.md.

Tab behind @, @@ or start completes the scripts in the directory tree of SQLPATH (and of the
working directory), one directory level at a time, without the extension .sql:

    SQL> @sess<TAB>        ->  @session/
    SQL> @session/swu<TAB> ->  @session/swuser

The hotkey (Alt-h, see zk_inputrc) shows the description and the parameters of the script on the line.

Only the Python standard library is used (Python 3.6 or newer).
"""

import os
import re
import sys
import traceback

# no __pycache__ in the directory of the Zauberkasten
sys.dont_write_bytecode = True

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

import zk_scriptdoc  # noqa: E402

# "@name", "@@name" or "start name": the name typed so far is group 1
CONTEXT_RE = re.compile(r'^\s*(?:@@?|start\s+)(\S*)$', re.IGNORECASE)
SCRIPT_RE = re.compile(r'^\s*(?:@@?|start\s+)(\S+)', re.IGNORECASE)

# rlwrap is started with -e '' (nothing is added behind a completion), so a space is added here
# behind a script name, but not behind a directory, to go on with the next level.
SPACE = ' '


def debug(text):
    """Appends a line to the file in ZK_FILTER_DEBUG (to see what rlwrap and the filter say to each other)."""
    path = os.environ.get('ZK_FILTER_DEBUG')
    if path:
        try:
            with open(path, 'a') as handle:
                handle.write(text + '\n')
        except OSError:
            pass


def current_directory():
    """Working directory of the client (sqlplus), else our own."""
    pid = os.environ.get('RLWRAP_COMMAND_PID', '')
    if pid.isdigit() and pid != '0':
        try:
            return os.readlink('/proc/%s/cwd' % pid)
        except OSError:
            pass
    return os.getcwd()


def search_roots(sqlpath=None, cwd=None):
    """Directories in which sqlplus looks for a script: the working directory, then SQLPATH."""
    if sqlpath is None:
        sqlpath = os.environ.get('SQLPATH', '')
    roots = []
    for entry in [cwd or current_directory()] + sqlpath.split(':'):
        if entry and os.path.isdir(entry) and entry not in roots:
            roots.append(entry)
    return roots


def plain_roots(sqlpath=None, cwd=None):
    """The working directory, unless it is one of the SQLPATH directories (those are script trees)."""
    if sqlpath is None:
        sqlpath = os.environ.get('SQLPATH', '')
    cwd = cwd or current_directory()
    return [] if cwd in sqlpath.split(':') else [cwd]


def contains_sql(path, depth=3, budget=300):
    """True if there is a .sql file in the directory or in a directory below it (a few levels, a few entries)."""
    todo = [(path, depth)]
    while todo and budget > 0:
        current, level = todo.pop(0)
        try:
            entries = list(os.scandir(current))
        except OSError:
            continue
        for entry in entries:
            budget -= 1
            try:
                if entry.is_dir():
                    if level > 1:
                        todo.append((entry.path, level - 1))
                elif entry.name.lower().endswith('.sql'):
                    return True
            except OSError:
                pass
    return False


def names_in(typed, roots, plain_roots=()):
    """Entries that continue the path 'typed' (the text behind @) on its last level.

    Directories get a trailing slash, scripts lose the extension .sql.
    Names that start with a dot or an underscore (_scriptinfo.txt ...) only show up if typed.
    In the directories of plain_roots (the working directory) only the directories that contain scripts
    are offered: it is no script tree like the ones in SQLPATH.
    """
    dirpart, _, leaf = typed.rpartition('/')
    if typed.startswith('/'):
        bases = [(dirpart or '/', False)]
    else:
        bases = [(os.path.join(root, dirpart) if dirpart else root, root in plain_roots) for root in roots]
    low = leaf.lower()
    found = {}
    for base, plain in bases:
        try:
            entries = list(os.scandir(base))
        except OSError:
            continue
        for entry in entries:
            name = entry.name
            if not name.lower().startswith(low):
                continue
            if name[0] in '._' and not leaf.startswith(name[0]):
                continue
            try:
                is_dir = entry.is_dir()
            except OSError:
                continue
            if is_dir:
                if not plain or contains_sql(entry.path):
                    found[name + '/'] = True
            elif name.lower().endswith('.sql') and len(name) > 4:
                found[name[:-4]] = True
    return sorted(found, key=lambda text: text.lower())


def complete(line, prefix, completions, roots, plain=()):
    """Completion handler: the script names behind @, otherwise rlwrap's own list unchanged.

    rlwrap is started with -c, then prefix is the whole path typed so far (session/swu). Where rlwrap
    breaks the word (at - + , and so on) it is only the end of it. The answers replace the prefix.
    """
    match = CONTEXT_RE.match(line)
    if not match:
        return completions
    typed = match.group(1)
    prefix = prefix or ''
    if not typed.endswith(prefix):
        return []
    cut = len(typed) - len(prefix)
    head = typed[:len(typed) - len(typed.rpartition('/')[2])]
    result = []
    for name in names_in(typed, roots, plain):
        word = (head + name)[cut:]
        result.append(word if name.endswith('/') else word + SPACE)
    return result


def find_script(name, roots):
    """Path of the script behind @name (sqlplus adds .sql), None if it is not found."""
    names = [name] if name.lower().endswith('.sql') else [name + '.sql', name]
    if name.startswith('/'):
        paths = names
    else:
        paths = [os.path.join(root, item) for root in roots for item in names]
    for path in paths:
        if os.path.isfile(path):
            return path
    return None


def terminal_width():
    """Width of the terminal of the user (the filter itself has no terminal)."""
    try:
        fd = os.open('/dev/tty', os.O_RDONLY)
        try:
            return os.get_terminal_size(fd).columns
        finally:
            os.close(fd)
    except OSError:
        pass
    try:
        return int(os.environ['COLUMNS'])
    except (KeyError, ValueError):
        return 80


def usage_text(name, path, width):
    """'swuser: description | 1: first parameter | 2: ...' cut to one line."""
    desc, params = zk_scriptdoc.script_info(path)
    parts = [name + (': ' + desc if desc else '')]
    parts += ['%d: %s' % (number, text) for number, text in params]
    text = ' | '.join(parts)
    width = max(width - 1, 20)
    return text if len(text) <= width else text[:width - 3] + '...'


def hotkey_message(line, roots, width):
    """Text for the echo area for the script on the line."""
    match = SCRIPT_RE.match(line)
    if not match:
        return 'no @script on this line'
    name = match.group(1)
    path = find_script(name, roots)
    if not path:
        return name + ': script not found in the working directory or SQLPATH'
    return usage_text(name, path, width)


def main():
    # rlwrapfilter.py: the library of the rlwrap that is running (sq.sh hands it over in ZK_FILTERLIB)
    for variable in ('ZK_FILTERLIB', 'RLWRAP_FILTERDIR'):
        if os.environ.get(variable):
            sys.path.append(os.environ[variable])
    import rlwrapfilter

    flt = rlwrapfilter.RlwrapFilter()
    flt.help_text = ('rlwrap -z "python3 zk_filter.py" sqlplus\n'
                     'Tab completion for @script, hotkey for description and parameters (SQL-Zauberkasten)\n')

    # An error in here must never get in the way of sqlplus: the input is passed on unchanged.
    def completion(line, prefix, completions):
        try:
            result = complete(line, prefix, completions, search_roots(), plain_roots())
            debug('completion line=%r prefix=%r rlwrap=%d -> %r' % (line, prefix, len(completions), result[:5]))
            return result
        except Exception:  # noqa: BLE001
            debug('completion failed: ' + traceback.format_exc())
            return completions

    def hotkey(key, prefix, postfix, history='', histpos=''):
        try:
            message = hotkey_message(prefix + postfix, search_roots(), terminal_width())
            debug('hotkey line=%r -> %r' % (prefix + postfix, message))
        except Exception:  # noqa: BLE001
            debug('hotkey failed: ' + traceback.format_exc())
            return [key, prefix, postfix, history, histpos]
        return [message, prefix, postfix, history, histpos]

    flt.completion_handler = completion
    flt.hotkey_handler = hotkey
    flt.run()


if __name__ == '__main__':
    main()
