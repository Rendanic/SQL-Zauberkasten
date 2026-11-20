#!/usr/bin/env python3
"""Tests for zk_filter.py and zk_scriptdoc.py (no rlwrap needed).

    python3 -m unittest rlwrap/test_zk_filter.py
"""

import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import zk_filter  # noqa: E402
import zk_scriptdoc  # noqa: E402


def write(root, relpath, text=''):
    path = os.path.join(root, relpath)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as handle:
        handle.write(text)
    return path


class TreeCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = self.tmp.name
        write(self.root, 'session/swuser.sql',
              '--\n-- Parameter 1: DB_USERNAME\n-- Parameter 2: SQL_ID\n--\nselect 1 from dual;\n')
        write(self.root, 'session/swall.sql', 'select 2 from dual;\n')
        write(self.root, 'session/_scriptinfo.txt',
              'swuser.sql        Sessions for a connected user\n'
              'swnodesc.sql\n')
        write(self.root, 'session/.hidden.sql')
        write(self.root, 'session/readme.txt')
        write(self.root, 'table/tab_info.sql')
        write(self.root, 'ee/dg/managed_status.sql')
        write(self.root, 'top.sql')
        write(self.root, 'Upper/CaseScript.sql')
        write(self.root, '_private/x.sql')
        write(self.root, 'dashes/my-script.sql')
        write(self.root, 'dots/a.b.sql')
        self.roots = [self.root]

    def tearDown(self):
        self.tmp.cleanup()


class NamesIn(TreeCase):
    def test_top_level(self):
        self.assertEqual(zk_filter.names_in('', self.roots),
                         ['dashes/', 'dots/', 'ee/', 'session/', 'table/', 'top', 'Upper/'])

    def test_one_level_at_a_time(self):
        self.assertEqual(zk_filter.names_in('sess', self.roots), ['session/'])
        self.assertEqual(zk_filter.names_in('session/', self.roots), ['swall', 'swuser'])
        self.assertEqual(zk_filter.names_in('session/swu', self.roots), ['swuser'])
        self.assertEqual(zk_filter.names_in('ee/dg/', self.roots), ['managed_status'])

    def test_case_is_ignored(self):
        self.assertEqual(zk_filter.names_in('SESS', self.roots), ['session/'])
        self.assertEqual(zk_filter.names_in('Upper/case', self.roots), ['CaseScript'])

    def test_hidden_names_only_when_typed(self):
        self.assertNotIn('_private/', zk_filter.names_in('', self.roots))
        self.assertEqual(zk_filter.names_in('_', self.roots), ['_private/'])
        self.assertNotIn('.hidden', zk_filter.names_in('session/', self.roots))
        self.assertEqual(zk_filter.names_in('session/.', self.roots), ['.hidden'])

    def test_only_sql_files(self):
        self.assertNotIn('readme.txt', zk_filter.names_in('session/', self.roots))
        self.assertNotIn('_scriptinfo.txt', zk_filter.names_in('session/_', self.roots))

    def test_two_roots_are_merged(self):
        other = tempfile.TemporaryDirectory()
        try:
            write(other.name, 'session/other.sql')
            write(other.name, 'extra/e.sql')
            roots = [self.root, other.name]
            self.assertEqual(zk_filter.names_in('session/', roots), ['other', 'swall', 'swuser'])
            self.assertIn('extra/', zk_filter.names_in('', roots))
            self.assertEqual(zk_filter.names_in('session/', roots).count('swall'), 1)
        finally:
            other.cleanup()

    def test_absolute_path(self):
        self.assertEqual(zk_filter.names_in(self.root + '/sess', []), ['session/'])
        self.assertEqual(zk_filter.names_in(self.root + '/session/sw', []), ['swall', 'swuser'])

    def test_unknown_directory(self):
        self.assertEqual(zk_filter.names_in('nothing/', self.roots), [])


class WorkingDirectory(TreeCase):
    """The working directory is no script tree: only directories with scripts are offered."""

    def setUp(self):
        super().setUp()
        write(self.root, 'photos/holiday.jpg')
        write(self.root, 'deep/a/b/c/x.sql')
        write(self.root, 'two/inner/y.sql')

    def test_script_tree_offers_every_directory(self):
        self.assertIn('photos/', zk_filter.names_in('', [self.root]))

    def test_working_directory_offers_directories_with_scripts_only(self):
        names = zk_filter.names_in('', [self.root], [self.root])
        self.assertNotIn('photos/', names)
        self.assertIn('session/', names)
        self.assertIn('two/', names)
        self.assertIn('top', names)

    def test_only_a_few_levels_deep(self):
        self.assertNotIn('deep/', zk_filter.names_in('', [self.root], [self.root]))

    def test_directories_below_are_checked_too(self):
        self.assertEqual(zk_filter.names_in('two/', [self.root], [self.root]), ['inner/'])

    def test_plain_roots(self):
        self.assertEqual(zk_filter.plain_roots('/a:/b', '/c'), ['/c'])
        self.assertEqual(zk_filter.plain_roots('/a:/b', '/b'), [])
        self.assertEqual(zk_filter.plain_roots('', '/c'), ['/c'])


class Complete(TreeCase):
    def run_complete(self, line, prefix, completions=()):
        return zk_filter.complete(line, prefix, list(completions), self.roots)

    def test_at_script_prefix_is_the_whole_path(self):
        # rlwrap -c: the prefix is the path typed so far
        self.assertEqual(self.run_complete('@sess', 'sess'), ['session/'])
        self.assertEqual(self.run_complete('@session/sw', 'session/sw'), ['session/swall ', 'session/swuser '])
        self.assertEqual(self.run_complete('@ee/dg/m', 'ee/dg/m'), ['ee/dg/managed_status '])

    def test_prefix_is_only_the_leaf(self):
        self.assertEqual(self.run_complete('@session/sw', 'sw'), ['swall ', 'swuser '])

    def test_directory_gets_no_space_script_gets_one(self):
        result = self.run_complete('@', '')
        self.assertIn('session/', result)
        self.assertIn('top ', result)

    def test_no_prefix_at_all(self):
        self.assertIn('session/', self.run_complete('@', None))

    def test_other_ways_to_start_a_script(self):
        self.assertEqual(self.run_complete('@@sess', 'sess'), ['session/'])
        self.assertEqual(self.run_complete('start sess', 'sess'), ['session/'])
        self.assertEqual(self.run_complete('START sess', 'sess'), ['session/'])
        self.assertEqual(self.run_complete('  @sess', 'sess'), ['session/'])

    def test_not_in_sql_text(self):
        own = ['select', 'session']
        self.assertEqual(self.run_complete('select * from sess', 'sess', own), own)
        self.assertEqual(self.run_complete('startup', 'startup', ['startup']), ['startup'])

    def test_not_behind_the_script_name(self):
        # "@session/swuser sw": the argument is not completed with script names
        self.assertEqual(self.run_complete('@session/swuser sw', 'sw', ['x']), ['x'])

    def test_word_breaks_of_rlwrap(self):
        # rlwrap also breaks words at - + , and so on: prefix is then only the end of the name
        self.assertEqual(self.run_complete('@dashes/my-s', 's'), ['script '])
        self.assertEqual(self.run_complete('@dashes/my-s', 'dashes/my-s'), ['dashes/my-script '])
        self.assertEqual(self.run_complete('@dots/a.', 'dots/a.'), ['dots/a.b '])

    def test_prefix_that_does_not_fit(self):
        self.assertEqual(self.run_complete('@sess', 'xyz'), [])


class FindScript(TreeCase):
    def test_extension_is_added(self):
        self.assertEqual(zk_filter.find_script('session/swuser', self.roots),
                         os.path.join(self.root, 'session/swuser.sql'))
        self.assertEqual(zk_filter.find_script('session/swuser.sql', self.roots),
                         os.path.join(self.root, 'session/swuser.sql'))

    def test_absolute(self):
        path = os.path.join(self.root, 'session/swuser')
        self.assertEqual(zk_filter.find_script(path, []), path + '.sql')

    def test_missing(self):
        self.assertIsNone(zk_filter.find_script('session/nothing', self.roots))
        self.assertIsNone(zk_filter.find_script('session', self.roots))


class HotkeyMessage(TreeCase):
    def message(self, line, width=200):
        return zk_filter.hotkey_message(line, self.roots, width)

    def test_description_and_parameters(self):
        self.assertEqual(self.message('@session/swuser 5'),
                         'session/swuser: Sessions for a connected user | 1: DB_USERNAME | 2: SQL_ID')

    def test_without_parameters_only_the_description(self):
        write(self.root, 'session/swnodesc.sql')
        self.assertEqual(self.message('@session/swnodesc'), 'session/swnodesc')

    def test_without_description_and_parameters(self):
        self.assertEqual(self.message('@session/swall'), 'session/swall')

    def test_script_not_found(self):
        self.assertIn('not found', self.message('@session/nothing'))

    def test_no_script_on_the_line(self):
        self.assertEqual(self.message('select 1 from dual'), 'no @script on this line')

    def test_cut_to_the_width(self):
        text = self.message('@session/swuser', width=40)
        self.assertEqual(len(text), 39)
        self.assertTrue(text.endswith('...'))


class ScriptDoc(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmp.cleanup()

    def params(self, text):
        path = write(self.tmp.name, 'x.sql', text)
        return zk_scriptdoc.parameters(path)

    def test_the_layout_is_recognised(self):
        self.assertEqual(self.params('-- Parameter 1: DB_USERNAME\n-- Parameter 2: SQL_ID\n'),
                         [(1, 'DB_USERNAME'), (2, 'SQL_ID')])

    def test_text_is_free_and_trimmed(self):
        self.assertEqual(self.params('-- Parameter 1:   owner of the table (default: all)   \n'),
                         [(1, 'owner of the table (default: all)')])
        self.assertEqual(self.params('-- Parameter 1:\n'), [(1, '')])

    def test_windows_line_endings(self):
        self.assertEqual(self.params('-- Parameter 1: OWNER\r\n'), [(1, 'OWNER')])

    def test_other_spellings_are_ignored(self):
        for line in ('--  Parameter 1: x',
                     '--Parameter 1: x',
                     '-- parameter 1: x',
                     '-- PARAMETER 1: x',
                     '-- Parameter 1. x',
                     '-- Parameter: x',
                     '-- Parameter 1 x',
                     'prompt Parameter 1: x',
                     'PROMPT Parameter 1: x',
                     '  -- Parameter 1: x',
                     'select 1 from dual; -- Parameter 1: x'):
            self.assertEqual(self.params(line + '\n'), [], line)

    def test_description(self):
        write(self.tmp.name, '_scriptinfo.txt', 'a.sql    First\nb.sql\tSecond  one \nc.sql\n')
        self.assertEqual(zk_scriptdoc.description(os.path.join(self.tmp.name, 'a.sql')), 'First')
        self.assertEqual(zk_scriptdoc.description(os.path.join(self.tmp.name, 'b.sql')), 'Second  one')
        self.assertEqual(zk_scriptdoc.description(os.path.join(self.tmp.name, 'c.sql')), '')
        self.assertEqual(zk_scriptdoc.description(os.path.join(self.tmp.name, 'd.sql')), '')

    def test_listed(self):
        write(self.tmp.name, '_scriptinfo.txt', 'a.sql    First\nb.sql\n')
        self.assertTrue(zk_scriptdoc.listed(os.path.join(self.tmp.name, 'a.sql')))
        self.assertTrue(zk_scriptdoc.listed(os.path.join(self.tmp.name, 'b.sql')))
        self.assertFalse(zk_scriptdoc.listed(os.path.join(self.tmp.name, 'c.sql')))

    def test_no_scriptinfo_and_missing_files(self):
        self.assertEqual(zk_scriptdoc.description(os.path.join(self.tmp.name, 'a.sql')), '')
        self.assertEqual(zk_scriptdoc.parameters(os.path.join(self.tmp.name, 'nothing.sql')), [])


if __name__ == '__main__':
    unittest.main()
