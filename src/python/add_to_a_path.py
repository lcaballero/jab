"""Script to display a collection of paths after inserting one new path

Usage:
    add_to_a_path.py [-U] PATHS PATH
    add_to_a_path.py [-U] (-s | -i INDEX ) PATHS PATH

Options:
    -h, --help               Show this help and exit
    -v, --version            Show version number and exit
    -s, --start              Add the path at start of list of paths
    -i INDEX, --index=INDEX  The index at which the path will be inserted


Examples of use:
    $ export PATH=/bin:/usr/bin

    $ add_to_a_path.py PATH /usr/local/bin
    /bin:/usr/bin:/usr/local/bin

    $ add_to_a_path.py PATH /usr/local/bin --start
    /usr/local/bin:/bin:/usr/bin


    $ add_to_a_path.py $PATH /usr/local/bin --index=1
    /bin:/usr/local/bin:/usr/bin

    $ add_to_a_path.py $PATH /not/a/real/path
    /bin:/usr/bin

"""


from __future__ import print_function
import os
import sys
import argparse
from bdb import BdbQuit


__version__ = '0.1.0'


class ScriptError(NotImplementedError):
    pass


def run_args(args, methods):
    """Run any methods eponymous with args"""
    if not args:
        return False
    valuable_args = {k for k, v in args.__dict__.items() if v}
    arg_methods = {methods[a] for a in valuable_args if a in methods}
    for method in arg_methods:
        method(args)


def version(args):
    print('%s %s' % (args, __version__))
    raise SystemExit


def parse_args(methods):
    """Parse out command line arguments"""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('symbol', help='The bash symbol to be changed')
    parser.add_argument('path', help='The path to be added')
    parser.add_argument('-s', '--start', action='store_true',
                        help='Add the path at start of list of paths')
    parser.add_argument('-i', '--index', type=int,
                        help='The index at which the path will be inserted')
    parser.add_argument('-v', '--version', action='store_true',
                        help='Show version')
    args = parser.parse_args()
    if not args.index:
        if args.start:
            args.index = 0
        else:
            args.index = False
    run_args(args, methods)
    return args


def _add_symbol_to_paths(paths, symbol, i):
    if i is False:
        i = len(paths)
    result = paths[:]
    if symbol:
        if symbol not in result:
            result.insert(i, symbol)
        else:
            j = result.index(symbol)
            if i != j:
                del result[j]
                result.insert(i, symbol)
    return result


def arg_path(args):
    path = args.path
    if not path:
        return ''
    user_path = os.path.expanduser(path)
    real_path = os.path.realpath(user_path)
    if not os.path.isdir(real_path):
        return ''
    return real_path


def split_paths(string):
    if not string:
        return []
    return [p for p in string.split(os.path.pathsep) if p]


def get_paths(args):
    symbol = args.symbol
    paths_string = ''
    if symbol in os.environ:
        paths_string = os.environ[symbol]
    elif os.path.pathsep in symbol:
        paths_string = symbol
    return split_paths(paths_string)


def script(args):
    path_symbol = arg_path(args)
    paths = get_paths(args)
    if not path_symbol:
        if not paths:
            return False
    elif os.path.isdir(path_symbol):
        paths = _add_symbol_to_paths(paths, path_symbol, args.index)
    else:
        return False
    print(os.path.pathsep.join(paths))
    return True


def main():
    """Run the script"""
    try:
        args = parse_args(globals())
        return os.EX_OK if script(args) else not os.EX_OK
    except (SystemExit, BdbQuit):
        pass
    return os.EX_OK


if __name__ == '__main__':
    sys.exit(main())
