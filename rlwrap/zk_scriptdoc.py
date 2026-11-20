#!/usr/bin/env python3
"""What the scripts of the SQL-Zauberkasten say about themselves.

Used by the rlwrap filter (zk_filter.py) and by tools/check_script_params.py.

Parameters are only recognised in this layout, one line per parameter:

    -- Parameter 1: DB_USERNAME
    -- Parameter 2: SQL_ID

Two dashes, one blank, "Parameter", the number, a colon. The text after the colon is free.
Other spellings ("prompt Parameter 1:", "-- Parameter 1.", "-- parameter 1:" ...) are ignored.

The one-line description of a script comes from the file _scriptinfo.txt in the same directory:

    swuser.sql        Sessions for a connected user from v$session
"""

import os
import re

PARAM_RE = re.compile(r'^-- Parameter ([0-9]+):\s*(.*?)\s*$')

MAX_BYTES = 1024 * 1024


def read_lines(path):
    """Lines of a script; unreadable or huge files give an empty list."""
    try:
        if os.path.getsize(path) > MAX_BYTES:
            return []
        with open(path, encoding='utf-8', errors='replace') as handle:
            return handle.read().splitlines()
    except OSError:
        return []


def parameters(path):
    """[(number, text)] of the '-- Parameter N: text' lines of a script, in file order."""
    found = []
    for line in read_lines(path):
        match = PARAM_RE.match(line)
        if match:
            found.append((int(match.group(1)), match.group(2)))
    return found


def description(path):
    """Description of a script from the _scriptinfo.txt of its directory, '' if there is none."""
    name = os.path.basename(path)
    for line in read_lines(os.path.join(os.path.dirname(path), '_scriptinfo.txt')):
        fields = line.split(None, 1)
        if fields and fields[0] == name:
            return fields[1].strip() if len(fields) > 1 else ''
    return ''


def listed(path):
    """True if the _scriptinfo.txt of the directory of the script has a line for it."""
    name = os.path.basename(path)
    for line in read_lines(os.path.join(os.path.dirname(path), '_scriptinfo.txt')):
        fields = line.split(None, 1)
        if fields and fields[0] == name:
            return True
    return False


def script_info(path):
    """(description, [(number, text)]) of a script."""
    return description(path), parameters(path)
