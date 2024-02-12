import abc as AbstractBaseClass
from enum import StrEnum
import json
from pathlib import Path
from uuid import uuid4

import yaml


def __genuuid__():
    return str(uuid4()).replace('-', '')

def genuuid():
    return str(uuid4())


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


class DataObject(DerivingObject):
    _data = dict({})

    __do_metaclass__ = AbstractBaseClass.ABCMeta
    __do_derived__ = None

    @staticmethod
    def file_write(self, fpath: Path, finput: str):
        return FileHandler.ds_write(fpath, finput)

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


def _dbion_tldbf_contents_get(dbname: str, dbext: str = 'yaml', known_dbs: [str] = [], dbroot: Path = _dbionpath, dbcollection: Path = _dblpath) -> dict:
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


def _db_symlinks_getdir() -> [Path]:
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

            dbsymlinkpath = Path(_dblpath.__str__() + '/' + _path_dir_get(dbpathstr))
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


class Singleton(type):
    def __init__(cls, name, bases, dict):
        super(Singleton, cls).__init__(name, bases, dict)
        cls.instance = None


class GlobalSingleton(object):
    metaclass = Singleton

    def __init__(self):
        super(GlobalSingleton, self).__init__(self)


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
    def loadds(ds: str) -> Yaml | dict:
        fpath = Path(_dbcpath).joinpath(ds + '.' + _dbext)
        if not fpath.exists():
            return dict()
        return FileHandler.ds_read(fpath, False)

    @staticmethod
    def lookup(field: str) -> str:
        # TODO:

        return ''
    
    
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
            else:
                for op in [' > ', ' < ', ' >= ', ' =< ']:
                    if cond.find(op) > -1:
                        self._op = op
                        pos_op = cond.find(op)
                        break
            
            # TODO: Admit ' and ' and ' or '
            if pos_op > -1:
                self._lhs = cond[:pos_op]
                self._rhs = cond[pos_op+len(self._op)+1:]
            else:
                self._lhs = cond


        def __init__(self, cond: str):
            self._parse(cond)
        
        # TODO Write eval and lookup() -> str
        def eval() -> bool:
            return True



    class Table:
        @staticmethod
        # tpath can be like 'persons.uid'
        def parse_tpath(tpath: str) -> dict:
            pos_last_dot = tpath.rfind('.')
            return dict(table=tpath[:pos_last_dot-1], field=tpath[pos_last_dot+1:])
        
        @staticmethod
        # Get the path of the table on filesystem
        def get_tpath(tpath: str) -> Path:
            tpath_dct = DBiON.Table.parse_tpath(tpath)
            return _dblpath.joinpath(tpath_dct['table'].replace('.', '/'))

        class Join:
            _joinlist = dict()

            # Join object can be found in the db.dbion.yml and the *.tbl.yml files
            def __init__(self, join_obj):
                self._joinlist['fields'] = join_obj['fields']
                self._joinlist['join_table'] = join_obj['join_table']
                self._joinlist['cond'] = join_obj['cond']
                if join_obj['alias'] is not None:
                    self._joinlist['alias'] = join_obj['alias']
                else:
                    self._joinlist['alias'] = ''

        class Definition(Yaml):
            _fields = []
            _cond = None
            _joins = []

            def get_fields(self) -> list[str]:
                return self._fields
        
            def get_condition(self) -> DBiON.Condition:
                return self._cond
            
            def get_table_joins(self) -> list[DBiON.Table.Join]:
                return self._joins

            @staticmethod
            def parse_joins(join_list: list[dict]) -> list[DBiON.Table.Join]:
                join_elems = []

                for join_elem in join_list:
                    join = DBiON.Table.Join(join_elem)
                    join_elem += join
                
                return join_elems

            def __init__(self, datastr: str):
                super().__init__(datastr)

                self._fields = self['fields']
                self._joins = self.parse_joins(self['joins'])
                if self['cond'] is not None:
                    self._cond = DBiON.Condition(self['cond'])

        _name = ''
        _tabledef = {}
        _def = None

        def get_definition(self) -> DBiON.Table.Definition:
            return self._def

        def __init__(self, table_yml: dict):
            self._name = table_yml['name']
            self._tabledef = table_yml
            self._def = DBiON.Table.Definition(table_yml)



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
            with open(fpath, 'r') as f
                fstr = f.read()
                f.close()
        except FileNotFoundError:
            if createfile:
                FileHandler.ds_write(fpath, '')

        return fstr


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
    
    # A DatasetFile has the format uid_tblid_ds_id.yml
    ## uid and tblid are optional.
    class DatasetFile:
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

        def __init__(self, uid: str = uuid4()[:7], ds_id: str = uuid4()[19:], tbl_id: str = uuid4()[9:17])
            if len(uid) > 0:
                self._uid = uid
            if len(tbl_id) > 0:
                self._tbl_id = tbl_id
            if len(ds_id) > 0:
                self._ds_id = ds_id

        def fname(self) -> str:
            fpn = ''
            if len(self._uid) > 0:
                fpn += self._uid + '_'
            elif len(self._tbl_id) > 0:
                fpn += self._tbl_id + '_'
            elif len(self._ds_id) > 0:
                fpn += self._ds_id
            return fpn + '.yml'
        
        def fpath(self) -> Path:
            return Path(self.fname())

