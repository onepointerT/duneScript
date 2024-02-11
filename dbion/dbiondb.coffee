import { stringify } from 'yaml/dist/stringify/stringify.js'
# dbiondb_config = require('dbiondb_config')

import './dbiondb.config.js'
import File from '../coffeelib/path.js'


path_dir_get: (dpathstr) ->
    paths = dpathstr[(dpathstr.find('/') || 0)..dpathstr.length()-1]
    if paths.length() is 0
        return dpathstr
    return paths


export class DataObject
    _check_compat: (datastr) ->
        return this._check_compat(datastr);

    is_compatible: (datastr) ->
        return _check_compat(datastr)

    parse_datastr: (datastr) ->
        return {}

    constructor: (datastr) ->
        @data = this.parse_datastr(datastr)

    get: (key) ->
        return @data[key]

    set: (key, value) ->
        return @data[key] = value

import YAML from 'yaml'


export class Yaml extends DataObject
    _check_compat: (datastr) ->
        return true
    
    data: () ->
        return @data

    parse_datastr: (datastr) ->
        @data = YAML.parse datastr
        return data()
    
    parse_file: () ->
        file = new File @filepath
        file_contents = file.read
        return parse_datastr file_contents

    stringify: () ->
        return YAML.stringify @data

    write_file: () ->
        file = new File @filepath
        return file.writeFile stringify()

    constructor: (@filepath, datastr = '') ->
        super datastr
        @data = parse_file()

    write: (fpath, finput) ->
        file = new Yaml fpath finput
        file.write_file stringify()
        return file

    read: (fpath) ->
        file = new Yaml fpath
        return file


import JSON5 from 'json5'

export class Json extends DataObject
    _check_compat: (datastr) ->
        return true
    
    data: () ->
        return @data

    parse_datastr: (datastr) ->
        @data = JSON5.parse datastr
        return data()
    
    parse_file: () ->
        file = new File @filepath
        file_contents = file.read
        return parse_datastr file_contents

    stringify: () ->
        return JSON5.stringify @data

    write_file: (fpath = @filepath) ->
        file = new File fpath
        return file.write stringify()

    read: (fpath) ->
        file = new Json fpath
        return file

    write: (fpath, finput) ->
        file = new Json fpath, finput
        file.write_file
        return file

    constructor: (@filepath, datastr = JSON5.load('{}')) ->
        super datastr
        @data = parse_file()


export class FileHandler
    ds_write: (fpath, finput) ->
        return Yaml.write fpath finput
    
    ds_read: (fpath) ->
        return Yaml.read fpath
    
    ds_write: (table, dsid, dscontent) ->
        path = table + '/' + dsid + '.yml'
        return FileHandler.ds_write path dscontent
    
    ds_read: (table, dsid) ->
        path = table + '/' + dsid + '.yml'
        return FileHandler.ds_read path
    
