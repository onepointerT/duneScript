import argparse
import subprocess


class CoffeeCompiler:
    @staticmethod
    def compile(path: str):
        if not path.find('.coffee'):
            try:
                with open(path) as f:
                    files = f.read()
                    f.close()
            except FileNotFoundError:
                files = '*.coffee'
            subprocess.run(['coffee', '--bare', '--no-header', '--compile', files])
        else:
            subprocess.run(['coffee', '--bare', '--no-header', '--compile', path])
        subprocess.run(['npm', 'run', 'flow'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser('coffeec', "Compile coffeescript")

    args = parser.parse_args()

    CoffeeCompiler.compile(args[0])

    exit(0)
