import argparse
from pathlib import Path
import os


class JadeCompiler:
    tld_path = './'

    @staticmethod
    def _subprocess_run_compile(filepath: str | Path):
        print("  -> Compiling '{0}'".format(filepath))

        # fp = filepath
        fp = filepath.__str__()

        # Recompile
        cmd = 'js haven/node_modules/jade/bin/jade.js -P --client -o {0}/html_jade {0}'.format(fp)
        print("    => {0}".format(cmd))

        if os.system(cmd) != 0:
            exit(1)

    @staticmethod
    def compile(pathstr: str | Path):

        print("JadeC '{0}'".format(pathstr))

        files = pathstr
        # If path is a e.g. directory, then we can use the listing from .coffeec
        path = Path(pathstr)

        return JadeCompiler._subprocess_run_compile(path)
        


if __name__ == '__main__':
    parser = argparse.ArgumentParser('jadec', "Compile jade")

    parser.add_argument('path', type=str, help='Path to start the compiler with.')

    args = parser.parse_args()

    if args.path is None or not Path(args.path).is_dir():
        print("Please specify a directory...")
        exit(1)
    else:
        print('args.path = "{0}"'.format(args.path))

    JadeCompiler.tld_path = Path(args.path)
    JadeCompiler.compile(str(args.path))

    exit(0)
