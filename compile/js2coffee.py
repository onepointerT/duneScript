import argparse
from glob import glob
from pathlib import Path
import os


class Js2CoffeeCompiler:
    tld_path = './'

    @staticmethod
    def _subprocess_run_compile(filepath: str | Path, bare=True):
        print("  -> Compiling '{0}'".format(filepath))

        if not filepath.is_file():
            return

        fp = filepath.__str__()
        pos_ext = fp.find('.js')
        fn = fp[:pos_ext]

        # Recompile
        cmd = 'js2coffee {0} > {1}.coffee'.format(fp, fn)
        print("    => {0}".format(cmd))

        if os.system(cmd) != 0:
            exit(1)

    @staticmethod
    def _handle_file_list(file_lst: list):
        for file in file_lst:
            filepath = file

            print("  -> '{0}'".format(filepath))

            if Path(filepath).is_dir():
                Js2CoffeeCompiler.compile(file)
            elif file.__str__().rfind('.coffeec') >= 0:
                continue
            elif file.__str__().rfind('.js') == len(file.__str__())-3:
                fp = file.__str__()

                print("  -> Js2Coffee '{0}'".format(fp))
                Js2CoffeeCompiler.compile(fp)
            else:
                continue

    @staticmethod
    def compile(pathstr: str | Path):

        print("Js2Coffee '{0}'".format(pathstr))

        files = pathstr
        # If path is a e.g. directory, then we can use the listing from .coffeec
        path = Path(pathstr)
        if path.is_dir():
            filelist = glob(path.__str__() + '/**')
            Js2CoffeeCompiler._handle_file_list(filelist)
        elif path.__str__().rfind('.js') != -1:
            Js2CoffeeCompiler._subprocess_run_compile(path)
        else:
            Js2CoffeeCompiler._subprocess_run_compile(files)


if __name__ == '__main__':
    parser = argparse.ArgumentParser('js2coffee', "Transpile javascript to coffeescript")

    parser.add_argument('path', type=str, help='Path to start the compiler with.')

    args = parser.parse_args()

    if args.path is None or not Path(args.path).is_dir():
        print("Please specify a directory...")
        exit(1)
    else:
        print('args.path = "{0}"'.format(args.path))

    Js2CoffeeCompiler.tld_path = Path(args.path)
    Js2CoffeeCompiler.compile(str(args.path))

    exit(0)
