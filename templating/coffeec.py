import argparse
import glob

from tmpl import JinjaEnvironment

if __name__ == '__main__':
    parser = argparse.ArgumentParser('coffeec', "Template and compile jinja")

    parser.add_argument('path', type=str, help='A path to the directory that is to be compiled')

    args = parser.parse_args()

    if args.path is None:
        print("Please specify a path.")
        exit(1)
    
    fp = str(args.path)
    files = glob.glob(fp, '**.jinja')

    env = JinjaEnvironment(fp)
    env.gen()

    exit(0)
