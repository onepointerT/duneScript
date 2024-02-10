import abc as AbstractBaseClass
from enum import StrEnum
import json
from pathlib import Path
from uuid import uuid4

import yaml


def __genuuid__():
    return str(uuid4()).replace('-', '')


## DB variables
_dbionpath = Path('./examples/dbion')
_dbpath = str('dbiondb')
_dbcpath = Path(_dbionpath.__str__() + '/' + _dbpath.__str__())
_dblpath = Path(_dbionpath.__str__() + '/db')

## DB environment
# Can be 'yaml' or 'json' (Json may be used for ResT-API-like compositors)
_dbext = 'yaml'
# ResT-API-like compositors may have the 'json' extension
_dbrestext = 'json'
_tldbfile = str('dbion.yml')

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


class DataObject(dict, DerivingObject, metaclass=AbstractBaseClass.ABCMeta):
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


class Yaml(DataObject):
    _data = yaml.YAMLObject()

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

    @staticmethod
    def is_compatible(self, datastr: str) -> bool:
        return self._check_compat(datastr, 'json')

    def parse_datastr(self, datastr: str) -> dict:
        if not self.is_compatible(datastr):
            return dict()
        return json.loads(datastr)

    @staticmethod
    def yaml(jsonobj: Json) -> object:
        pass

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
    _known_dbs: [str] = [str]
    _hardlink: bool = False

    def __init__(self, dbionpath = './examples/dbion', known_dbpaths: [str] = { '/dbion1' }):
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
