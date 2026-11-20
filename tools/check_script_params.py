#!/usr/bin/env python3
"""Report which scripts of the SQL-Zauberkasten do not follow the layout for parameters yet.

Nothing is changed. The layout is one line per parameter in the header of the script:

    -- Parameter 1: DB_USERNAME
    -- Parameter 2: SQL_ID

The tab completion of rlwrap (rlwrap/zk_filter.py) only shows parameters in this layout.

    python3 tools/check_script_params.py            report with the names of the scripts
    python3 tools/check_script_params.py --quiet    only the numbers
    python3 tools/check_script_params.py --sql-dir DIR
"""

import argparse
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, 'rlwrap'))

import zk_scriptdoc  # noqa: E402

POSITIONAL_RE = re.compile(r'&&?([0-9]+)')
COMMENT_RE = re.compile(r'^\s*(--|rem(\s|$)|prompt(\s|$))', re.IGNORECASE)


def scripts(sql_dir):
    found = []
    for base, dirs, files in os.walk(sql_dir):
        dirs.sort()
        found += [os.path.join(base, name) for name in sorted(files) if name.lower().endswith('.sql')]
    return found


def used_positionals(path):
    """Numbers of the &N and &&N in the code of a script (comments and prompt lines are skipped)."""
    used = set()
    for line in zk_scriptdoc.read_lines(path):
        if not COMMENT_RE.match(line):
            used.update(int(number) for number in POSITIONAL_RE.findall(line))
    return used


def check(sql_dir):
    """Dictionary: kind of finding -> list of scripts, plus the numbers for the summary."""
    findings = {'missing': [], 'numbering': [], 'incomplete': [], 'unlisted': []}
    total = with_used = with_layout = 0
    for path in scripts(sql_dir):
        total += 1
        used = used_positionals(path)
        documented = [number for number, _ in zk_scriptdoc.parameters(path)]
        name = os.path.relpath(path, sql_dir)
        if used:
            with_used += 1
        if documented:
            with_layout += 1
        if used and not documented:
            findings['missing'].append(name)
        if documented and documented != list(range(1, len(documented) + 1)):
            findings['numbering'].append(name)
        if documented and used and max(used) > len(documented):
            findings['incomplete'].append(name)
        if not zk_scriptdoc.listed(path):
            findings['unlisted'].append(name)
    return findings, {'scripts': total, 'with &N': with_used, 'with -- Parameter N:': with_layout}


TITLES = {
    'missing': "uses &N but has no '-- Parameter N:' line",
    'numbering': "'-- Parameter N:' lines do not count 1, 2, 3 ...",
    'incomplete': "uses a higher &N than there are '-- Parameter N:' lines",
    'unlisted': 'is not in the _scriptinfo.txt of its directory',
}


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--sql-dir', default=os.path.join(REPO, 'sql'), help='directory of the scripts (default: sql)')
    parser.add_argument('--quiet', '-q', action='store_true', help='only the numbers, not the names of the scripts')
    args = parser.parse_args()

    if not os.path.isdir(args.sql_dir):
        sys.exit('%s: no such directory' % args.sql_dir)
    findings, numbers = check(args.sql_dir)
    print(', '.join('%s: %d' % item for item in numbers.items()))
    for kind in ('missing', 'numbering', 'incomplete', 'unlisted'):
        names = findings[kind]
        print('\n%d scripts: %s' % (len(names), TITLES[kind]))
        if not args.quiet:
            for name in names:
                print('  ' + name)


if __name__ == '__main__':
    main()
