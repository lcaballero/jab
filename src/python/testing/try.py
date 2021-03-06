"""Script to handle running of doctests"""


from __future__ import print_function

import re
import os
import imp
import sys
import doctest
import commands
import datetime
from pprint import pprint


from six.moves import cStringIO as StringIO

from dotsite.paths import path
from see import see, see_methods, see_attributes, spread
import files_for_test
import try_plugins


class DoctestInterrupt(KeyboardInterrupt):
    """This exception is for better naming of the only thing to stop doctest"""


def no_print(method, *args, **kwargs):
    """Discard all writes to stdout"""
    old_stdout = sys.stdout
    try:
        sys.stdout = StringIO()
        return method(*args, **kwargs)
    finally:
        sys.stdout = old_stdout


def run_command(command):
    """Run a command in the local shell (usually bash)"""
    status, output = commands.getstatusoutput(command)
    if status:
        print('FAIL: %s:%s' % (status, output))
        return False
    print(output)
    return True


def show(thing):
    """Pretty print the given thing

    Unless the thing is a module
        when we show the help for that module instead
    """
    if isinstance(thing, type(re)):
        return pprint(help(thing))
    return pprint(thing)


class TestBeingRun(object):
    """Encapsulation of the current test"""

    def __init__(self, that):
        self.here = path('.')
        self.home = path('~')
        self.username = os.environ['USER']
        try:
            self.host = os.environ['HOST']
        except KeyError:
            try:
                self.host = os.environ['HOSTNAME']
            except KeyError:
                self.host = None
                if self.home.startswith('/Users'):
                    self.host = 'jab.ook'
        self.user = '%s@%s' % (self.username, self.host)
        self.path = self.here.relpathto(that)
        base, _ext = self.path.splitext()
        [self.add_path(base, _) for _ in ['py', 'test', 'tests', 'fail']]

    def __repr__(self):
        return '<%s %r>' % (self.__class__.__name__, str(
            self.path.short_relative_path_from_here()))

    def add_path(self, base, ext):
        """Add a path for base.ext as an attribute to self"""
        name = 'path_to_%s' % ext
        if hasattr(self, name):
            return
        path_to_ext = path('%s.%s' % (base, ext))
        if path_to_ext.isfile() or ext == 'fail':
            setattr(self, name, path_to_ext)


def parse_args():
    """Handle args on the command line

    Destroy the option parser when finished
        (do not interfere with tests which use it)
    """
    # Hello future me , please convert to argparse
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    pa = parser.add_argument
    pa('stems', metavar='stems', type=str, nargs='*',
       help='stems to be tested (e.g "try.py" or "try.*" or "try." or "try/"')
    pa('-s', '--show', help='show files being tested', action='store_true')
    pa('-v', '--verbose', help='Hello World', action='store_true')
    pa('-r', '--recursive', action='store_true',
       help='recurse into any sub-directories found',)
    pa('-a', '--all', action='store_true',
       help="run all tests (don't stop on first FAIL)",)
    pa('-d', '--directory_all', action='store_true',
       help='run all test scripts in a directory'
       '(do not stop on first FAILing script)',)
    pa('-q', '--quiet_on_success', action='store_true',
       help='no output if all tests pass',)
    pa('-p', '--persist', action='store_true',
       help='do not stop on DoctestInterrupts',)
    args = parser.parse_args()
    # Try not to interfere with any ArgumentParser used in script under test
    if hasattr(parser, 'destroy'):
        parser.destroy()
    del parser
    if args.recursive:
        stems = [_ for _ in args.stems if os.path.isfile(_)]
        if not stems:
            return args
        raise ValueError(
            'Do not use --recursive with stems ("%s")' % (
            '"%s", '.join(stems)))
    return args


class SysPathHandler(object):

    def __init__(self):
        self.paths = []

    def add(self, item):
        """Add the item to sys.path"""
        directory = path(item).directory()
        if directory not in self.paths:
            self.paths.insert(0, directory)
            if directory not in sys.path:
                sys.path.insert(0, str(directory))

    def remove(self, item):
        """Remove the item from sys.path"""
        directory = path(item).directory()
        if directory in self.paths:
            self.paths.remove(directory)
            if directory in sys.path:
                sys.path.remove(directory)


def make_module(path_to_python):
    """The module object for the given python source code"""
    name = path_to_python.namebase
    try:
        return sys.modules[name]
    except KeyError:
        pass
    try:
        fp, pathname, description = imp.find_module(
            name, [path_to_python.parent])
    except ImportError:
        try:
            fp, pathname, description = (
                open(name), path_to_python, ('', 'r', imp.PY_SOURCE))
        except IOError:
            raise ImportError('Could not find a module for %r' %
                              str(path_to_python))
    # If any of the following calls raises an exception,
    # there's a problem we can't handle -- let the caller handle it.
    try:
        x = imp.load_module(name, fp, pathname, description)
        return x
    finally:
        if fp:
            fp.close()


def test_source(source_script):
    """Run tests in the given source"""
    message = 'py %s;' % source_script
    module = make_module(source_script)
    failures, tests_run = doctest.testmod(
        module,
        optionflags=get_doctest_options(),
        verbose=args.verbose,
    )
    del module
    return failures, tests_run, message


def test_file(test_script):
    """Run tests in a doctest script"""
    message = 'try %s;' % test_script
    failures, tests_run = doctest.testfile(
        test_script,
        optionflags=get_doctest_options(),
        module_relative=False,
        globs={
            'test': TestBeingRun(test_script),
            'sys': sys,
            'see': see,
            'spread': spread,
            'see_methods': see_methods,
            'see_attributes': see_attributes,
            'makepath': path,
            'show': show,
            'bash': run_command,
            'DoctestInterrupt': DoctestInterrupt,
            'no_print': no_print,
        },
        verbose=args.verbose,
    )
    return failures, tests_run, message


def run_doctest(test_script):
    """Call the relevant doctest method for the given script"""
    if test_script.ext in ['', '.py']:
        try:
            return test_source(test_script)
        except ImportError:
            if test_script.ext:
                raise
            return 0, 0, ''
    return test_file(test_script)


def show_running_doctest(test_script):
    """Run a doctest for that script, showing progress on stdout/stderr"""
    old_argv = sys.argv[:]
    try:
        sys.argv = [test_script]
        try:
            if args.verbose or args.show:
                print('Test', test_script)
            return run_doctest(test_script)
        except DoctestInterrupt as e:
            if args.directory_all or args.persist:
                show_interruption(test_script, e)
                return 0, 0, ''
            raise
        except SyntaxError as e:
            if args.directory_all or args.persist:
                show_syntax(test_script, e)
                return 0, 0, ''
            raise
    finally:
        sys.argv[:] = old_argv


def get_doctest_options():
    """Convert the command line args to Doctest flags"""
    result = doctest.ELLIPSIS | doctest.NORMALIZE_WHITESPACE
    if not args.all:
        result |= doctest.REPORT_ONLY_FIRST_FAILURE
    return result


def show_time_taken(start, messages, message, tests_run):
    """Add a message about the time taken dince start to the messages"""
    end = datetime.datetime.now()
    time_taken = end - start
    if time_taken.seconds:
        if time_taken.seconds > 1:
            time_msg = 'in %d seconds' % time_taken.seconds
        else:
            time_msg = 'quickly'
    else:
        time_msg = 'very quickly'
    messages.append('%s %s tests passed %s' % (message, tests_run, time_msg))
    return end


def show_syntax(test_script, interruption):
    """Show the reason for an interuption on stderr"""
    print('Bye from ', test_script, file=sys.stderr)
    print('Because:', interruption, file=sys.stderr)


def show_interruption(test_script, interruption):
    """Show the reason for an interuption on stderr"""
    print('^c ^C ^c ^C ^c ^C ^c ^C ^c ^C ^c ', file=sys.stderr)
    print('Bye from ', test_script, file=sys.stderr)
    print('Because:', interruption, file=sys.stderr)


args = None

def test():
    """Run all tests"""
    sys_paths = SysPathHandler()
    global args
    args = parse_args()
    messages = ['']
    pwd = os.getcwd()
    end = start_all = datetime.datetime.now()
    run_all = 0
    failures_all = 0
    sys_paths.add('.')
    try:
        for test_script in files_for_test.paths_to_doctests(
                args.stems, args.recursive):
            failures, tests_run, message = 0, 0, ''
            os.chdir(pwd)
            start = datetime.datetime.now()
            try:
                sys_paths.add(test_script)
                if try_plugins.pre_test(test_script):
                    failures, tests_run, message = show_running_doctest(
                        test_script)
                    try_plugins.post_test(test_script, failures, tests_run)
            finally:
                sys_paths.remove(test_script)
            if tests_run:
                run_all += tests_run
                end = show_time_taken(start, messages, message, tests_run)
            else:
                show_time_taken(start, messages, message, tests_run)
            if failures:
                failures_all += failures
                if not args.directory_all:
                    return failures
    finally:
        time_taken = end - start_all
        messages.append('%s tests passed, %d failed, in %s seconds' %
                        (run_all, failures_all, time_taken.seconds))
        messages.append('')
    if failures_all or not args.quiet_on_success:
        print('\n'.join(messages))
    return failures_all


def main():
    """Run the program"""
    try:
        return test()
    except files_for_test.UserMessage as e:
        print(e, file=sys.stderr)
    except KeyboardInterrupt as e:
        print('^c ^C ^c ^C ^c ^C ^c ^C ^c ^C ^c ', file=sys.stderr)
        print('Bye now', file=sys.stderr)
        if str(e):
            print(e, file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
