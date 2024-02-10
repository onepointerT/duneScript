import argparse
from pathlib import Path
import os


class CoffeeCompiler:
    tld_path = './'

    @staticmethod
    def _subprocess_run_compile(filepath: str | Path, bare=True):
        print("  -> Compiling '{0}'".format(filepath))

        if filepath.__str__().rfind('.coffeec') > -1:
            return
        elif filepath.__str__().rfind('*.coffee') > -1:
            return

        # Does not work at the moment
        # subprocess.run(['npm', 'run', 'flow'])

        # fp = filepath
        fp = filepath.__str__()

        # Recompile
        cmd = 'coffee --bare --no-header --compile {0}'.format(fp)
        print("    => {0}".format(cmd))

        os.system(cmd)

    @staticmethod
    def _handle_file_list(file_lst: list):
        for file in file_lst:
            filepath = file

            print("  -> '{0}'".format(filepath))

            if Path(filepath).is_dir():
                CoffeeCompiler.compile(file)
            elif file.__str__().rfind('.coffeec') >= 0:
                continue
            elif file.__str__().rfind('.coffee') >= 0:
                fp = file.__str__()

                print("  -> CoffeeC '{0}'".format(fp))
                CoffeeCompiler.compile(fp)
            else:
                CoffeeCompiler.compile(file.__str__())

    @staticmethod
    def compile(pathstr: str | Path):

        print("CoffeeC '{0}'".format(pathstr))

        files = pathstr
        # If path is a e.g. directory, then we can use the listing from .coffeec
        path = Path(pathstr)
        if path.__str__().rfind('.coffee') == -1 and path.is_dir():
            try:
                print("-> Reading '{0}/.coffeec'".format(pathstr))
                with open(path.joinpath('.coffeec')) as f:
                    files = f.read()
                    f.close()

                print("-> '{0}/.coffeec':".format(path))

                if files.__str__().find('.coffee') == -1 or path.__str__().rfind('*.coffee'):
                    file_lst = []
                    for file in path.iterdir():
                        if file.__str__().rfind('.coffeec') > -1:
                            continue
                        elif file.__str__().rfind('.coffee') > -1:
                            file_lst.append(file.__str__())
                            # file_lst.append(CoffeeCompiler.tld_path + '/' + pathstr + '/' + file.__str__())

                    print("  -> Found {0} in .coffeec".format(file_lst))

                    CoffeeCompiler._handle_file_list(file_lst)

                if files.find(' ') > -1:
                    file_lst = files.split(' ')

                    print("  -> Found {0} in .coffeec".format(file_lst))

                    for i, file in enumerate(file_lst):
                        file_lst[i] = path.__str__() + '/' + file.__str__()

                    CoffeeCompiler._handle_file_list(file_lst)
                else:
                    CoffeeCompiler.compile(pathstr.__str__() + '/' + files)
            except FileNotFoundError:
                print("File not found.")
                # files = '*.coffee'
                # CoffeeCompiler._subprocess_run_compile(files)

        elif path.__str__().rfind('.coffee') != -1 and path.__str__().rfind('.coffeec') == -1:
            CoffeeCompiler._subprocess_run_compile(path)
        elif files.is_dir():
            CoffeeCompiler.compile(path)
        else:
            CoffeeCompiler._subprocess_run_compile(files)


if __name__ == '__main__':
    parser = argparse.ArgumentParser('coffeec', "Compile coffeescript")

    parser.add_argument('path', type=str, help='Path to start the compiler with.')

    args = parser.parse_args()

    if args.path is None or not Path(args.path).is_dir():
        print("Please specify a directory...")
        exit(1)
    else:
        print('args.path = "{0}"'.format(args.path))

    CoffeeCompiler.tld_path = Path(args.path)
    CoffeeCompiler.compile(str(args.path))

    exit(0)
