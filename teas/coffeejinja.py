import argparse
import glob

from tmpl import JinjaCoffeeTemplate, JinjaEnvironment, JinjaTemplate
from ..dbion.dbiondb import Yaml

if __name__ == '__main__':
    parser = argparse.ArgumentParser('coffee_jinja', "Template and compile coffeescript and jinja")

    parser.add_argument('path', type=str, help='A path to the file that is to be compiled')
    parser.add_argument('-coffee', type=str, help='A coffeescript-like file with jinja templating for coffeescript. Then uses "{#" and "#}" as delimiters. With this option path optionally can be a directory.')
    parser.add_argument('-yml', type=str, help='A path to the templating parameters for jinja. Defaults to $path.jinja.yml')

    args = parser.parse_args()

    if args.path is None:
        print("Please specify a path.")
        exit(1)
    
    fp = str(args.path)
    jinja_yml_path = str(fp)
    if args.yml is not None:
        jinja_yml_path = str(args.yml)
        yml = Yaml.from_file(jinja_yml_path)
    else:
        yml = dict()

    if args.coffee is not None:
        files = glob.glob(fp, '**.jinja.coffee')

        env = JinjaEnvironment(files)
        env.gen()

        ct = JinjaCoffeeTemplate(str(args.coffee), yml)
        ct.generateTo(str(args.coffee).replace('.jinja', ''))
    else:
        jt = JinjaTemplate(fp, yml)
        jt.generateToFile()

    exit(0)
