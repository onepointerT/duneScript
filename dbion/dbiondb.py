import abc as AbstractBaseClass
import json
from pathlib import Path
from shutil import copyfile
from uuid import uuid4

import yaml


def __genuuid__():
    return str(uuid4()).replace('-', '')

def genuuid():
    return str(uuid4())

def genid():
    return str(genuuid()[:9])


## DB variables
_dbionpath = Path('./examples')
_dbpath = str('dbiondb')
_dbcpath = Path(_dbionpath.__str__() + '/' + _dbpath.__str__())
_dblpath = Path(_dbionpath.__str__() + '/db')

## DB environment
# Can be 'yaml' or 'json' (Json may be used for ResT-API-like compositors)
_dbext = 'yaml'
# ResT-API-like compositors may have the 'json' extension
_dbrestext = 'json'
_tldbfile = str('.dbion.yml')

## Templating environment
_templating_globals = 'templating/globals.' + _dbext
_templating_globals_path = Path(_dbcpath.__str__() + '/' + _templating_globals)
# Define a global templating file for each language (html, jinja, css, coffee, python)

## Debug environment
_debug = True
def printdbg(*values: object):
    if _debug:
        print(values)


def path_dir_get(dpathstr: str) -> str:
    paths = dpathstr[dpathstr.rfind('/'):len(dpathstr)-1]
    if len(paths) == 0:
        return dpathstr
    return paths


class DerivingObject(object, metaclass=AbstractBaseClass.ABCMeta):
    __derived__ = None

    @classmethod
    def subfunc(cls, other, name: str):
        func = getattr(other, name)
        return func


class FileHandler:
    @staticmethod
    def ds_write(fpath: Path, finput: str):
        with open(fpath, 'rw') as f:
            f.write(finput)
            f.close()

    @staticmethod
    def ds_read(fpath: Path, createfile = True) -> Yaml:
        try:
            with open(fpath, 'r') as f:
                yml = yaml.safe_load(f)
                f.close()
        except FileNotFoundError:
            if createfile:
                FileHandler.ds_write(fpath, '')

        return Yaml(yml)

    @staticmethod
    def fread(fpath: Path, createfile = False):
        fstr = str()
        try:
            with open(fpath, 'r') as f:
                fstr = f.read()
                f.close()
        except FileNotFoundError:
            if createfile:
                FileHandler.ds_write(fpath, '')

        return fstr
    
    @staticmethod
    def fwrite(fpath: Path, fcontent: str):
        with open(fpath, 'rw') as f:
            f.write(fcontent)
            f.close()


    @staticmethod
    def _ds_path_get(table: str, dsid: str, createdirs = True) -> Path:
        dpath = Path(_dblpath.__str__() + '/' + table)
        if not dpath.exists() and createdirs:
            dpath.mkdir(parents=True, exist_ok=True)
        return Path(dpath.__str__() + '/' + dsid + '.' + _dbext)

    @staticmethod
    def ds_read(table: str, dsid: str) -> str:
        fpath = FileHandler._ds_path_get(table, dsid)
        if not fpath.is_file() and not fpath.is_dir():
            return str()
        with open(fpath, 'r') as f:
            fcontent = f.read()
            f.close()
        return fcontent

    @staticmethod
    def ds_write(table: str, dsid: str, dscontent: str) -> bool:
        fpath = FileHandler._ds_path_get(table, dsid)
        if not fpath.is_file() and not fpath.is_dir():
            fpath.touch()
        with open(fpath, 'rw') as f:
            f.write(dscontent)
            f.close()
        return True


class DataObject(DerivingObject):
    _data = dict({})

    __do_metaclass__ = AbstractBaseClass.ABCMeta
    __do_derived__ = None

    @staticmethod
    def file_write(self, fpath: Path, finput: str):
        return FileHandler.fwrite(fpath, finput)

    def write(self, fpath: Path, finput: str = '')
        if len(finput) == 0:
            finput = self.subfunc(self.__do_derived__, 'tostring')(self)
        return DataObject.file_write(fpath, finput)

    @staticmethod
    def file_read(self, table: str, dsid: str):
        return self.parse_datastr(FileHandler.ds_read(table, dsid))

    @AbstractBaseClass.abstractmethod
    def _parse_datastr(self, datastr: str) -> dict:
        return dict({})

    @AbstractBaseClass.abstractmethod
    def _check_compat(self, datastr: str) -> bool:
        return self.subfunc(self.__do_derived__, '_check_compat')(datastr)

    def _check_compat(self, datastr: str, compat_ext: str) -> bool:
        if compat_ext.find('yaml') < 0 and compat_ext.find('json') < 0:
            return False
        return self.subfunc(self.__do_derived__, '_check_compat')(datastr)

    @staticmethod
    def is_compatible(self, datastr: str) -> bool:
        return self._check_compat(datastr)
    
    @AbstractBaseClass.abstractmethod
    def tostring(self) -> str:
        return str(self._data)

    @staticmethod
    def from_file(self, fpath: Path):
        yml = str()
        if fpath.exists() and fpath.is_file():
            with open(fpath, 'rw') as f:
                yml= yaml.safe_load(f)
                f.close()
        return yml

    def parse_datastr(self, datastr: str) -> dict:
        if self.is_compatible(datastr):
            return self.subfunc(self.__do_derived__, '_parse_datastr')(datastr)
        return dict({})

    def __init__(self, datastr: str):
        self.__derived__ = self.__do_derived__
        self._data = self.parse_datastr(datastr)

    def __getattr__(self, key):
        return self._data[key]

    def __setattr__(self, key, value):
        self._data[key] = value

    def __dict__(self):
        return self._data

    def __iter__(self):
        return self._data.__iter__()
    
    def __str__(self) -> str:
        return self.subfunc(self.__do_derived__, 'tostring')(self)


class Yaml(DataObject):
    _data = yaml.YAMLObject()

    def tostring(self) -> str:
        return str(self._data.dump())

    def parse_datastr(self, datastr: str) -> dict:
        with datastr as stream:
            self._data = yaml.safe_load(stream)
            stream.close()
        return self._data

    def __init__(self, datastr: str):
        self.__do_derived__ = Yaml
        super(Yaml, self).__init__(datastr)


class Json(DataObject):
    _data = json.loads('{}')

    def _check_compat(self, datastr: str) -> bool:
        return datastr.find('{') < datastr.find('}')

    def tostring(self) -> str:
        return json.dumps(self._data)

    @staticmethod
    def is_compatible(self, datastr: str) -> bool:
        return self._check_compat(datastr, 'json')

    def parse_datastr(self, datastr: str) -> dict:
        if not self.is_compatible(datastr):
            return dict()
        return json.loads(datastr)

    @staticmethod
    def yaml(jsonobj) -> Yaml:
        return Yaml(str(jsonobj))

    def __init__(self, datastr: str):
        self.__do_derived__ = Json
        super(Json, self).__init__(datastr)



def _dbion_path_test(createdir = True) -> bool:
    if _dbionpath.exists():
        return True
    elif createdir:
        _dbionpath.mkdir(parents=True, exist_ok=True)
        return True
    return False


def _dbion_path_set(dpathstr: str, createdir = True) -> bool:
    global _dbionpath
    _dbionpath = Path(dpathstr)
    if _dbionpath.is_dir():
        return True

    return _dbion_path_test(createdir)


def _dbion_tldbf_contents_get(dbname: str, dbext: str = 'yaml', known_dbs: list[str] = [], dbroot: Path = _dbionpath, dbcollection: Path = _dblpath) -> dict:
    return dict(
        dbname = dbname,
        dbroot = dbroot,
        dbcollection = dbcollection,
        known_dbs = known_dbs,
        dbext = dbext
    )


def _dbion_create_db_tlf(tlfpath: Path, dbname: str):
    FileHandler.ds_write(tlfpath, _dbion_tldbf_contents_get(dbname))


def _db_path_test(createdir = True) -> bool:
    if _dbcpath.exists():
        return True
    elif createdir:
        _dbcpath.mkdir(parents=True, exist_ok=True)
        return True
    return False


def _db_path_set(dbpathstr: str, createdir = True) -> bool:
    global _dbpath
    global _dbcpath

    _dbpath = dbpathstr
    _dbcpath = Path(_dbionpath.__str__() + '/' + _dbpath.__str__())

    return _db_path_test(createdir)


def _db_path_get(dpathstr: str) -> Path:
    return Path(_dbcpath + '/' + dpathstr)


def _db_test_compatibility(dpathstr: str) -> bool:
    dpath = Path(dpathstr)
    if dpath.exists():
        # Every database has a file called '.dbion' in the top-level directory
        tldb = Path(dpath.__str__() + '/' + _tldbfile.__str__())
        if tldb.exists() and tldb.is_file():
            return True
        elif not tldb.exists():
            _db_create(dpathstr)
    return False


# TODO: Honor last directory's name as dbname
def _db_create(dbpathstr: str):
    dbpath = Path(dbpathstr)
    if not dbpath.exists():
        dbpath.mkdir(parents=True, exist_ok=True)

    # Every database has a file called '.dbion' in the top-level directory
    tldb = Path(dbpath.__str__() + '/' + _tldbfile.__str__())
    if not tldb.exists():
        return _dbion_create_db_tlf(Path(dbpathstr + '/' + _tldbfile))

    return True


def _db_symlinks_getdir() -> list[Path]:
    return [dirs for dirs in _dblpath.iterdir() if dirs.is_dir()]

def _db_symlink_hasone(dbpathstr: str) -> bool:
    return _dblpath.match(dbpathstr)

def _db_symlinks_find(dbpathstr: str) -> Path:
    if _db_symlink_hasone(dbpathstr):
        return Path(_dblpath.__str__() + '/' +  dbpathstr)
    return Path()


def _db_symlink(dbpathstr: str, createdir = False) -> bool:
    dpath = Path(dbpathstr)
    dbtestcompat = _db_test_compatibility(dbpathstr)

    def _db_symlink_make(dbpathstr: str):
        dbpath = Path(dbpathstr)
        if dbpath.is_dir():
            if not _dblpath.exists():
                _dblpath.mkdir(parents=True, exist_ok=True)

            dbsymlinkpath = Path(_dblpath.__str__() + '/' + dbpathstr)
            dbsymlinkpath.mkdir(parents=True, exist_ok=True)

            dbsymlinkpath.symlink_to(dbpath, target_is_directory=True)
            return True
        return False

    if not dpath.exists() and not _db_path_test(createdir):
        return False
    elif not dbtestcompat and createdir:
        if _db_create(dbpathstr):
            return _db_symlink_make(dbpathstr)
        return False
    elif dbtestcompat:
        return _db_symlink_make(dbpathstr)
    return False

def _db_eval_dbext() -> str:
    if _dbext == 'yaml':
        return 'yml'
    elif _dbext == 'json':
        return 'json'
    else:
        return 'coffee'


class BivariateDict(AbstractBaseClass):
    @AbstractBaseClass.abstractmethod
    def default_values() -> dict:
        return dict()
    
    _dct = default_values()

    def __init__(self):
        self._dct = self.default_values()
    
    def keys(self):
        return self._dct.keys()
    
    def values(self):
        return self._dct.values()
    
    def pairs(self) -> list[list]:
        pairlist = list[list]()
        for i, key in enumerate(self.keys()):
            val = [key, self.values()[i]]
            pairlist.append(val)
        return pairlist
    
    def __getattr__(self, key):
        return self._dct[key]
    
    def __setattr__(self, key, value):
        self._dct[key] = value
    
    def __iter__(self):
        return self._dct.values()
    
    def dict(self) -> dict:
        return self._dct


class Variable(BivariateDict):
    def default_values() -> dict:
        return dict(
                    varstr = '',
                    prefix = '',
                    hasprefix = True,
                    tablename = '',
                    fieldname = '',
                    ref_op = '',
                    dereference = False, # For any conclusion on which order to dereference and lookup
                    lookup = False,   # you must have a look at prefix
                    filestr = '',
                    filename = '',
                    fileext = '',
                    matchall = False,
                    field_list = list[str]()
                )
    
    # Specs from `dbion/README.md`
    #
    #### Syntax and semantics of lookup variables
    #
    # In a mapping of joins, rjoins or requests, a field value is referenced with a trailing '$'
    # - '**' indicates any value, even when there is a list of values or a list of lists or similar
    # - '*rjoins*' matches any ID of the JSON field rjoins: {}
    # - Similar, '*$tablename1/tablename2.id*' algorithmically matches any ID of the dbion table tablename1/tablename2 field value id
    # - $Path.Field means, that a field value is to be looked up
    # - $tablename1/#tablename2.fieldA means, that tablename2 will be subsituted by the table id and fieldA is then looked up
    # - $#Path.Field would dereference path to its table ids and then lookup field
    # - #$Path.Field would first lookup $Path.Field and then dereference Path (e.g. useful for compare conditions and storing after lookup)
    # - $$Path[.[FieldA,FieldB]] can lookup a whole set of table data
    # - |filename[||ext]| filters by filenames, where filename usually is something like [$uid]_#tblid_**
    # - A new ID can be generated with '##'
    # - paths without operator prefix always mean the value of a field in a table (prefixed with table(s).) or the current value of a field in the current table
    #
    # That's all what can happen ;)
    def parse(self, varstr: str) -> bool:
        self._dct['varstr'] = varstr

        # First test, if we start with an allof-lookup
        if varstr.find('*') == 0 and varstr.rfind('*') == len(varstr)-1:
            self._dct['matchall'] = True
            self._dct['matchall_varstr'] = varstr[1:len(varstr)-1] # Now without the allow-stars
            varstr = str(self._dct['matchall_varstr'])
        
        # Now for the prefix
        if varstr.find('$#') == 0 or varstr.find('#$') == 0:
            self._dct['prefix'] = varstr[0:1]
            self._dct['dereference'] = True
            self._dct['lookup'] = True
            varstr = varstr[2:]
        elif varstr.find('#') == 0:
            self._dct['prefix'] = '#'
            self._dct['lookup'] = True
        elif varstr.find('$$') == 0: # With this option, the allof-matcher '**' can be omitted, a list of fields may follow
            self._dct['prefix'] = '$$'
            self._dct['matchall'] = True
            self._dct['lookup'] = True
            
            if varstr.rfind('[') > -1:
                flstr = varstr[varstr.rfind('[')+1:len(varstr)-1]
                fieldlist = flstr.split(',')
                self._dct['fieldlist'] = fieldlist
        elif varstr.find('$') == 0:
            self._dct['prefix'] = '$'
            self._dct['lookup'] = True
        else:
            self._dct['hasprefix'] = False

        vbrace_pos = varstr.find('|')
        if vbrace_pos > -1:  # If there is something like "fname": "|uname_#users_||req.yml|"
            vbrace_rpos = varstr.rfind('|')
            self._dct['filestr'] = varstr[vbrace_pos:vbrace_rpos]

            filestr = str(self._dct['filestr'])
            vbrace_dpos = filestr.find('||')
            if vbrace_dpos > -1: # Yes, has a file extension given
                self._dct['fileext'] = filestr[vbrace_dpos+2:len(filestr)-2]
                self._dct['filename'] = filestr[1:vbrace_dpos-1]
            else:
                self._dct['filename'] = filestr[1:len(filestr)-2]
            
            varstr = varstr[:vbrace_pos-1] + varstr[vbrace_rpos+1:]
        
        dpos = varstr.rfind('.')
        if dpos > -1:
            self._dct['fieldname'] = varstr[dpos+1:]
            self._dct['tablename'] = varstr[:dpos-1]
        else:
            self._dct['fieldname'] = varstr[:]


    def __init__(self, varstr: str):
        super().__init__()

        self.parse(varstr)
    
    
class Condition:
    _lhs = ''
    _rhs = ''
    _op = ''
    _lhc = None
    _rhc = None

    def _parse(self, cond: str):
        pos_op = -1
        if cond.find(' is ') > -1:
            self._op = ' is '
            pos_op = cond.find(' is ')
        elif cond.find(' isnt ') > -1:
            self._op = ' isnt '
            pos_op = cond.find(' isnt ')
        elif cond.find(' and ') > -1:
            self._op = ' and '
            pos_op = cond.find(' and ')
        elif cond.find(' or ') > -1:
            self._op = ' or '
            pos_op = cond.find(' or ')
        else:
            for op in [' > ', ' < ', ' >= ', ' =< ']:
                if cond.find(op) > -1:
                    self._op = op
                    pos_op = cond.find(op)
                    break
        
        if pos_op > -1:
            self._lhs = cond[:pos_op]
            self._rhs = cond[pos_op+len(self._op)+1:]
        else:
            self._lhs = cond
        
        if self._op == ' and ' or self._op == ' or ':
            self._lhc = Condition(self._lhs)
            self._rhs = Condition(self._rhs)


    def __init__(self, cond: str):
        self._parse(cond)
    
    # TODO Write eval with lookup() -> str
    def eval(self) -> bool:
        if self._op == ' and ':
            return (self._lhc.eval() and self._rhc.eval())
        elif self._op == ' or ':
            return (self._lhc.eval() or self._rhc.eval())
        elif self._op == ' is ':
            return (self._lhs == self._rhc)
        elif self._op == ' isnt ':
            return (self._lhs != self._rhs)
        return True


# This can finally lookup and dereference variables
class LookupRequest(Variable):
    _ds = None
    
    def __init__(self, varstr: str):
        super().__init__(varstr)

    @staticmethod
    def get_table_id(tablename: str) -> str:
        tables_json = Json(Json.from_file(_dbionpath + '/tables.json'))
        table_ids = Json(tables_json['table_ids'])
        if table_ids[tablename] is None:
            id = genid()
            tables_json['table_ids'][tablename] = id
            tables_json.write(_dbionpath + '/tables.json')
            table_ids = Json(tables_json['table_ids'])
        return str(table_ids[tablename])
    
    # A short set of regex is used, '**', dereference of a table's id and filtering by file extension
    def filter_dir_by_fileregex(self, filedir: str | Path) -> list[Path] | list[str]:
        filedirstr = str(filedir)
        if filedirstr.find(_dbcpath) == -1:  # The top-level directory of a lookup request is ever the database's db directory
            filedirstr = _dbcpath + '/' + filedir  # Try to correct to the current db path with sub-level-directory filedir
        
        dbtdir = Path(filedirstr)
        if not dbtdir.exists():
            return []  # We failed with listing the files, the table's directory does not exist in database
        
        dbt_dir_files = list[Path]
        if len(self._dct['filename']) > 0:
            filename_filter = str(self._dct['filename'])

            # Dereference all IDs found in the filestr
            while filename_filter.find('#') > -1:
                pos_deref = filename_filter.find('#')
                
                # If '##', please gen one id.
                if filename_filter[pos_deref:pos_deref+1] == '##':
                    id = genid()

                    filename_filter[pos_deref:pos_deref+1] = id

                else:
                    
                    deref_tbl = self.get_table_id(filename_filter[pos_deref+1:filename_filter.find('_', pos_deref)-1])
                    replace_str = filename_filter[pos_deref:filename_filter.find('_', pos_deref)-1]
                    filename_filter.replace(replace_str, deref_tbl)
            
            printdbg("'{0} dereferenced to {1}".format(self._dct['filename'], filename_filter))
            self._dct['filename'] = filename_filter

        if len(self._dct['fileext']) > 0 and len(self._dct['filename']) > 0:
            dbt_dir_files = dbtdir.glob(self._dct['filename'] + '.' + self._dct['fileext'])
        elif len(self._dct['fileext']) > 0:
            dbt_dir_files = dbtdir.glob('**.' + self._dct['fileext'])
        elif len(self._dct['filename']) > 0:
            dbt_dir_files = dbtdir.glob(self._dct['filename'] + '**')
        else:
            return []
        
        return dbt_dir_files
        

    ## Sometimes we want to dereference to a table's  or a dataset id
    @staticmethod
    def dereference(tablehirarchy: str) -> str:
        while tablehirarchy.find('#') > -1:
            pos_deref = tablehirarchy.find('#')
            
            
            pos_next_table_name = tablehirarchy.find('/', pos_deref)
            if pos_next_table_name == -1:
                pos_next_table_name = tablehirarchy.find('.', pos_deref)
            if pos_next_table_name == -1:
                pos_next_table_name = len(tablehirarchy) - 1
            
            deref_tbl = LookupRequest.get_table_id(tablehirarchy[pos_deref+1:pos_next_table_name-1])
            replace_str = tablehirarchy[pos_deref+1:pos_next_table_name-1]
            tablehirarchy.replace(replace_str, deref_tbl)

        if tablehirarchy.rfind('.') > -1:  # A field value is omitted for better convenience and usability
            tablehirarchy = tablehirarchy[:tablehirarchy.rfind('.')-1]

        return tablehirarchy
    
    ## Often we want to lookup a field's value
    @staticmethod
    def lookup(self, tablename: str, fieldnames: list[str] | str, ds_cond: Condition = None) -> list[str] | list[Yaml]:
        # TODO
        tabledir = Path(_dbcpath + '/' + LookupRequest.dereference(tablename))
        if not _db_test_compatibility(tabledir):
            return []
        
        lup_rq = LookupRequest('{1}.{2}|**||{0}|'.format(_dbext, tablename, fieldname))
        tabledir_content = lup_rq.filter_dir_by_fileregex(tabledir)

        yml = list[Yaml]()
        for file in tabledir_content:
            fp = Path(file)

            # TODO: Extension handling
            fc = Yaml(Yaml.from_file(fp.absolute()))

            if type(fieldnames) == str:
                fieldnames = [fieldnames]

            # TODO: Eval conditional lookup
            if ds_cond is not None and not ds_cond.eval():
                continue

            yml_current = Yaml('')
            for fieldname in fieldnames:
                yml_current[fieldname] = fc[fieldname]
            
            yml.append(yml_current)

        return yml
    
    def eval(self) -> list[str] | list[Yaml]:
        lup_rq = LookupRequest.lookup(self._dct['tablename'], self._dct['fieldname'])
        if len(lup_rq) == 0:
            raise LookupError("Could not lookup {0}".format(self._dct['varstr']))
        return lup_rq

    ## If there is a file given, we may read it or lookup the whole relative path starting with _dbiondir
    def handle_file(self) -> bool | Path | Yaml | Json:
        if len(self._dct['filename']) == 0:
            return False  # We don't know about a file
        
        filename = self._dct['filename']
        filepath = Path(filename)
        if len(self._dct['fileext']) == 0 and filename.find('.') == -1:
            return False  # We didn't find a file extension
        elif filename.find('.') > -1:
            return filepath # The filepath has an extension
        elif len(self._dct['fileext']) > 0: # An extension is given
            filepath = Path(filename + '.' + self._dct['fileext'])


class Singleton(type):
    def __init__(cls, name, bases, dict):
        super(Singleton, cls).__init__(name, bases, dict)
        cls.instance = None


class GlobalSingleton(object):
    metaclass = Singleton

    def __init__(self):
        super(GlobalSingleton, self).__init__(self)


class TableJoin:
    _joinlist = dict(
        fields = list[str](),
        table_joining = '',
        cond = None,
        condstr = '',
        alias = ''
    )

    # Join object can be found in the db.dbion.yml and the *.tbl.yml files
    def __init__(self, join_obj):
        self._joinlist['fields'] = join_obj['fields']
        self._joinlist['table_joining'] = join_obj['table_joining']
        self._joinlist['condstr'] = join_obj['cond']
        if join_obj['alias'] is not None:
            self._joinlist['alias'] = join_obj['alias']
        else:
            self._joinlist['alias'] = ''
    
    def joinlist(self) -> dict:
        return self._joinlist
    


class TableDefinition(Variable, Yaml):
    _fields = []
    _cond = None
    _joins = list[TableJoin]()

    @staticmethod
    def parse_joins(join_list: list[dict]) -> list[TableJoin]:
        join_elems = []

        for join_elem in join_list:
            join = TableJoin(join_elem)
            join_elem += join
        
        return join_elems
    
    @staticmethod
    def make_table_dir(tpath: str, tfields: list[str]):
        if tpath.find('#') > -1:  # We need to dereference the ids of the tables
            tpath = LookupRequest.dereference(tpath)
        if tpath.find('$$') > -1:
            tpath = tpath[2:]
        elif tpath.find('$') > -1:
            tpath = tpath[1:]
        
        tbl_dir = Path(_dbcpath + '/' + tpath)
        if not tbl_dir.exists():
            tbl_dir.mkdir(parents=True, exist_ok=True)
        
        # TODO: Create tbl.yml
        yml = Yaml('table: {}')
        yml['table']['name'] = tpath
        yml['table']['fields'] = tfields
        yml['table']['cond'] = ''
        yml_tfile = tbl_dir + '/' + tpath.replace('/', '_') + '.tbl.yml'
        yml.write(yml_tfile)
        copyfile(yml_tfile, _dbionpath + '/dbiondb/' + tpath.replace('/', '_') + '.tbl.yml')


        return tbl_dir
    
    def make_directory(self) -> Path:
        return TableDefinition.make_table_dir(self._dct['tablename'], self._data['fields'])

    def __init__(self, datastr: str):
        super(Yaml, self).__init__(datastr)
        super(Variable, self).__init__(self._data['name'])

        self._fields = self['fields']
        self._joins = self.parse_joins(self['joins'])
        if self['cond'] is not None:
            self._cond = Condition(self['cond'])
    
    def fields(self) -> list[str]:
        return self._fields
    
    def condition(self) -> Condition:
        return self._cond
    
    def joinlist(self) -> list[TableJoin]:
        return self._joins


class Table(TableDefinition):
    @staticmethod
    # tpath can be like 'persons.uid'
    def parse_tpath(tpath: str) -> dict:
        pos_last_dot = tpath.rfind('.')
        return dict(table=tpath[:pos_last_dot-1], field=tpath[pos_last_dot+1:])
    
    @staticmethod
    # Get the path of the table on filesystem
    def get_tpath(tpath: str) -> Path:
        tpath_dct = Table.parse_tpath(tpath)
        return _dblpath.joinpath(tpath_dct['table'].replace('.', '/'))

    _name = ''
    _tbl_id = ''
    _tabledef = {}

    def get_definition(self) -> TableDefinition:
        return super(TableDefinition, self)

    def __init__(self, table_yml: dict):
        self._name = table_yml['name']
        self._tabledef = table_yml

        super(TableDefinition, self).__init__(table_yml)



class DataRequest(Yaml):
    _rq_dir = Path(_dbionpath + '/data_request')
    _tmp = _rq_dir.joinpath('tmp')
    
    def __init__(self, request_dir: str, fname: str):
        fp = Path(request_dir).joinpath(fname)
        if not fp.exists() or not fp.is_file():
            super().__init__('')
        else:
            with open(fp, 'r') as f:
                datastr = f.read()
                f.close()
            super().__init__(datastr)

        if len(request_dir) > 0:
            self._rq_dir = Path(request_dir)
            self._tmp = Path(request_dir).joinpath('tmp')



def __new_json_str() -> str:
    return str('{}')


def __new_json_obj() -> json:
    return json.loads(__new_json_str())

# A DatasetFile has the format uid_tblid_ds_id.yml
## uid and tblid are optional.
class DatasetFile(Path):
    _uid = uuid4()[:7]
    _tbl_id = uuid4()[9:17]
    _ds_id = uuid4()[19:]
    
    @staticmethod
    def parse_filename(self, fname: str) -> dict:
        fn = self.fname()
        dct = dict(uid='', tbl_id='', ds_id='')
        # There is UserId, TableId and DatasetId set for this file
        if fn.count('_') == 2:
            pos_delim1 = fn.find('_')
            pos_delim2 = fn.find('_', pos_delim1+1)

            dct['uid'] = fn[:pos_delim1-1]
            dct['tbl_id'] = fn[pos_delim1+1:pos_delim2-1]
            dct['ds_id'] = fn[pos_delim2+1:]
        elif fn.count('_'):
            pos_delim = fn.find('_')
            delim1 = fn[:pos_delim-1]

            if delim1.count('-') == 0:
                dct['ds_id'] = delim1
            else:
                dct['tbl_id'] = delim1
            
            dct['ds_id'] = fn[pos_delim+1:]
        else:
            dct['ds_id'] = fn

    def __init__(self, uid: str = '', ds_id: str = '', tbl_id: str = ''):
        fname = ''
        if len(uid) > 0:
            self._uid = uid
            fname += uid
        
        fname += '_'
        if len(tbl_id) > 0:
            self._tbl_id = tbl_id
            fname += tbl_id
        
        fname += '_'
        if len(ds_id) > 0:
            self._ds_id = ds_id
        
        fname += '.' + _db_eval_dbext()
        super(Path, self).__init__(fname)

    def fname(self) -> str:
        fpn = ''
        if len(self._uid) > 0:
            fpn += self._uid + '_'
        elif len(self._tbl_id) > 0:
            fpn += self._tbl_id + '_'
        elif len(self._ds_id) > 0:
            fpn += self._ds_id
        return fpn + '.' + _db_eval_dbext()
    
    def fpath(self) -> Path:
        return Path(self.fname())


class DBiON(GlobalSingleton):
    _known_dbs: list[str] = [str]
    _hardlink: bool = False

    def __init__(self, dbionpath = './examples/dbion', known_dbpaths: list[str] = { '/dbion1' }):
        super(DBiON, self).__init__()
        self._known_dbpaths = known_dbpaths
        _dbion_path_set(dbionpath)
        _db_path_set('db')

    @staticmethod
    def dbpath_default():
        return _dblpath

    @staticmethod
    def dbpath_globals_templating():
        return _templating_globals_path

    @staticmethod
    def dbext():
        return _dbext
    
    @staticmethod
    def debug(dbg_on = True):
        global _debug
        _debug = dbg_on

    @staticmethod
    def loadds(ds: str) -> Yaml | dict:
        fpath = Path(_dbcpath).joinpath(ds + '.' + _dbext)
        if not fpath.exists():
            return dict()
        return FileHandler.ds_read(fpath, False)

    @staticmethod
    def lookup(field: str) -> str:
        lru_rq = LookupRequest(field)

        return lru_rq.eval()
    
    @staticmethod
    def create_table(tdef: str) -> TableDefinition:
        tbl_def = TableDefinition(tdef)
        tbl_def.make_table_dir()
        return tbl_def
