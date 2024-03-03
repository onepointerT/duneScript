from pathlib import Path
from jinja2 import Environment, Template
from dbion import DBiON, FileHandler, Yaml, path_dir_get


## For non-jinja-like files there could/should be another set of variable delimiters
_variable_start_string = '{{-'
_variable_end_string = '-}}'


def load_globals_from_ds(fname: Path, tmpl_name: str = str()) -> dict:
    if len(tmpl_name) > 0:
        fpath = DBiON.dbpath_globals_templating().joinpath(tmpl_name + '.' + DBiON.dbext())
    else:
        fpath = DBiON.dbpath_globals_templating().joinpath(fname)

    return dict(FileHandler.ds_read(fpath, False))


def load_globals_from_ds_multi(ds_paths: list = [str]):
    tmpl_globals = dict()
    for ds_path in ds_paths:
        tmpl_globals += DBiON.loadds(ds_path)
    return tmpl_globals

# TODO: Load Jinja values from database
class JinjaTemplate:
    _template = None
    _globals = dict()
    _fpath = Path()

    def _update_template(self):
        self._template = Template(FileHandler.fread(Path(self._fpath)))

    def __init__(self, fpathstr: str, globals: dict = dict()):
        self._fpath = Path(fpathstr)
        if not self._fpath.exists() or not self._fpath.is_file():
            raise FileNotFoundError('The template file "{0}" was not found'.format(fpathstr))

        self._update_template()
        self.update_globals(globals)

        fname = path_dir_get(fpathstr)
        self._template.name = fname
        self._template.filename = fname

    def update_globals(self, globals: dict = dict()):
        if len(globals) == 0:
            globals_path = DBiON.dbpath_globals_templating()
            globals_file = FileHandler.ds_read(globals_path, False)
            globals = dict(globals_file)

        self._globals = globals
        if self._template is not None:
            self._template.globals = self._globals

    def generate(self):
        print("=> Generating '{0}'".format(self._fpath))
        return self._template.render()

    def generateToFile(self):
        html = self.generate()
        with open(self._fpath + '.html', 'rw') as f:
            f.write(html)
            f.close()
        return html

    # If a file could change on disk, use this function (this is happening since we loaded the file in the constructor)
    def generate_now(self):
        self._update_template()
        self.update_globals()
        return self.generate()

    # For HTML templating a template should be generated twice,
    # once recursively fetch includes, once update it's globals
    def generate_plus_includes(self, *args, **kwargs):
        self._template = Template(self.generate(args, kwargs))
        old_template = self._template
        while self._template.find('{% include') > -1:
            self._template = Template(self.generate(args, kwargs))
        self._template = old_template
        return self.generate(args, kwargs)


class JinjaCoffeeTemplate(JinjaTemplate):
    def __init__(self, fpathstr: str, globals: dict = dict()):
        super(JinjaCoffeeTemplate, self).__init__(fpathstr, globals)
        self._template = Template(FileHandler.fread(Path(fpathstr)), variable_start_string=_variable_start_string, variable_end_string=_variable_end_string)

        fname = path_dir_get(fpathstr)
        self._template.name = fname
        self._template.filename = fname

    def generate(self):
        return self._template.render()
    
    def generateTo(self, fpath):
        tmpl_gen = self.generate_now()
        with open(fpath, 'rw') as f:
            f.write(tmpl_gen)
            f.close()
        return tmpl_gen

    @staticmethod
    def gen(fpath, topath = ''):
        jct = JinjaCoffeeTemplate(fpath)

        if len(topath) > 0:
            jc = jct.generateTo(topath)
        else:
            jc = jct.generate_now()
        
        return jc
    

class JinjaEnvironment:
    _env = Environment(variable_start_string=_variable_start_string, variable_end_string=_variable_end_string)
    _known_templates: list = [Path]

    def __init__(self, known_templates: list = [Path]):
        self._known_templates = known_templates

    def templates(self):
        return self._known_templates

    def environment(self) -> Environment:
        return self._env
    
    def gen(self):
        for path in self._known_templates:
            if path.__str__().find('.jinja.coffee'):
                JinjaCoffeeTemplate.gen(path.__str__(), path.__str__().replace('.jinja', ''))
