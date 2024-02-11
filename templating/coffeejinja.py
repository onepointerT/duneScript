import argparse
import glob

from tmpl import JinjaEnvironment

if __name__ == '__main__':
    parser = argparse.ArgumentParser('coffee_jinja', "Template and compile coffeescript and jinja")

    parser.add_argument('path', type=str, help='A path to the directory that is to be compiled')

    args = parser.parse_args()

    if args.path is None:
        print("Please specify a path.")
        exit(1)
    
    fp = str(args.path)
    files = glob.glob(fp, '**.jinja.coffee')

    env = JinjaEnvironment(files)
    env.gen()

    exit(0)
