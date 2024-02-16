#import { Directory } from '../coffeelib/path.coffee'
import { stringify } from 'yaml/dist/stringify/stringify.js'
# dbiondb_config = require('dbiondb_config')

import './dbiondb.config.js'
import { Conditional } from '../coffeelib/conditional.js'
import * as path from '../coffeelib/path.js'
import { strfind, strfindr, strreplace, listtostr } from '../coffeelib/str.js'


path_dir_get: (dpathstr) ->
    paths = dpathstr[(dpathstr.find('/') || 0)..dpathstr.length()-1]
    if paths.length() is 0
        return dpathstr
    return paths



class BivariateDict extends {}
    @default_values: () -> return {};
    
    constructor: () ->
        super(default_values())


export class DataObject
    _check_compat: (datastr) ->
        return this._check_compat(datastr);

    is_compatible: (datastr) ->
        return _check_compat(datastr)

    parse_datastr: (datastr) ->
        return {};

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
        file = new path.File @filepath
        file_contents = file.read
        return parse_datastr file_contents

    stringify: () ->
        return YAML.stringify @data

    write_file: () ->
        file = new path.File @filepath
        return file.writeFile stringify()

    constructor: (@filepath, datastr = '') ->
        super datastr
        @data = parse_file()

    @write: (fpath, finput) ->
        file = new Yaml fpath finput
        file.write_file stringify()
        return file

    @read: (fpath) ->
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
        file = new path.File @filepath
        file_contents = file.read
        return parse_datastr file_contents

    stringify: () ->
        return JSON5.stringify @data

    write_file: (fpath = @filepath) ->
        file = new path.File fpath
        return file.write stringify()

    @read: (fpath) ->
        file = new Json fpath
        return file

    @write: (fpath, finput) ->
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
    

class Variable extends BivariateDict
    @default_values: () -> return {
        varstr: ''
        prefix: ''
        hasprefix: true
        tablename: ''
        fieldname: ''
        ref_op: ''
        dereference: false # For any conclusion on which order to dereference and lookup
        lookup: false   # you must have a look at prefix
        filestr: ''
        filename: ''
        fileext: ''
        matchall: false
        fieldlist: []
    }

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
    parse: (varstr) ->
        this['varstr'] = varstr

        # First test, if we start with an allof-lookup
        if strfind(varstr, '*') == 0 and strfindr(varstr, '*') == varstr.length-1
            this['matchall'] = true
            this['matchall_varstr'] = varstr[1..varstr.length-2]
            varstr = this['matchall_varstr']
        
        # Now for the prefix
        if strfind(varstr, '$#') == 0 or strfind('#$') == 0
            this['prefix'] = varstr[0..1]
            this['dereference'] = true
            this['lookup'] = true
            varstr = varstr[2..]
        else if strfind(varstr, '#') == 0
            this['prefix'] = '#'
            this['lookup'] = true
            varstr = varstr[1..]
        else if strfind(varstr, '$$') == 0 # With this option, the allof-matcher '**' can be omitted, a list of fields may follow
            this['prefix'] = '$$'
            this['matchall'] = true
            this['matchall_varstr'] = varstr[2..]
            this['lookup'] = true
            varstr = varstr[2..]

            if strfindr(varstr, '[') > -1
                flstr = varstr[strfind(varstr, '[')+1..varstr.length-2]
                fieldlist = flstr.split(',')
                this['fieldlist'] = fieldlist
            
        else if strfind(varstr, '$') == 0
            this['prefix'] = '$'
            this['lookup'] = true
            varstr = varstr[1..]

        else
            this['hasprefix'] = false

        vbrace_pos = strfind(varstr, '|')
        if vbrace_pos > -1  # If there is something like "fname": "|uname_#users_||req.yml|"
            vbrace_rpos = strfindr(varstr, '|')
            this['filestr'] = varstr[vbrace_pos..vbrace_rpos]

            filestr = this['filestr']
            vbrace_dpos = strfind(filestr, '||')
            if vbrace_dpos > -1 # Yes, has a file extension given
                this['fileext'] = filestr[vbrace_dpos+2..filestr.length-2]
                this['filename'] = filestr[1..vbrace_dpos-1]
            else
                this['filename'] = filestr[1..filestr.length-2]
            
            varstr = varstr[..vbrace_pos-1] + varstr[vbrace_rpos+1..]
        
        dpos = strfindr(varstr, '.')
        if dpos > -1
            this['fieldname'] = varstr[dpos+1..]
            this['tablename'] = varstr[..dpos-1]
        else
            this['fieldname'] = varstr


    constructor: (varstr) ->
        super()
        this.parse(varstr)


genuuidv4: () ->
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        .replace(/[xy]/g, (c) =>
            r = Math.random() * 16 | 0
            v = c == 'x' ? r : (r & 0x3 | 0x8)
            return v.toString(16)
        )

genuuid: () -> genuuidv4()
genid: () ->genuuid()[..7]


class LookupRequest extends Variable
    constructor: (varstr) ->
        super(varstr)
    
    @get_table_id: (tablename) ->
        tables_json = new Json(Json.read(dbiondb_config.db.path + '/tables.json'))
        table_ids = new Json(tables_json['table_ids'])
        if table_ids[tablename] != null
            id = genid()
            tables_json['table_ids'][tablename] = id
            tables_json.write_file(dbiondb_config.db.path + '/tables.json')
            table_ids = new Json(tables_json['table_ids'])
        return table_ids[tablename]
    
    # A short set of regex is used, '**', dereference of a table's id and filtering by file extension
    filter_dir_by_fileregex: (filedir) ->
        filedirstr = new String(filedir)
        if strfind(filedir, dbiondb_config.db.path) == -1
            filedirstr = dbiondb_config.db.path + '/' + filedir
        
        dbtdir = new path.Directory(filedirstr)
        if not dbtdir.exists()
            return []  # We failed with listing the files, the table's directory does not exist in database

        if String(this['filename']).length > 0
            filename_filter = String(this['filename'])

            while strfind(filename_filter, '#') > -1
                pos_deref = strfind(filename_filter, '#')

                if filename_filter[pos_deref..pos_deref+1] == '##'
                    id = genid()
                    filename_filter = filename_filter.replace('##', id)
                else
                    deref_tbl = this.get_table_id(filename_filter[pos_deref+1..strfind(filename_filter, '_')-1])
                    replace_str = filename_filter[pos_deref..strfind(filename_filter, '_', pos_deref)-1]
                    filename_filter.replace(replace_str, deref_tbl)
            
            this['filename'] = filename_filter
        
        if this['fileext'].length > 0 and this['filename'] > 0
            dbt_dir_files = dbtdir.getEntriesByRegex(this['filename'] + '.' + this['fileext'])
        else if this['fileext'].length > 0
            dbt_dir_files = dbtdir.getEntriesByRegex('*.*' + this['fileext'])
        else if this['filename'].length > 0
            dbt_dir_files = dbtdir.getEntriesByRegex(this['filename'] + '*')
        else
            return []

        return dbt_dir_files

    ## Sometimes we want to dereference to a table's  or a dataset id
    @dereference: (tablehirarchy) ->
        while strfind(tablehirarchy, '#') > -1
            pos_deref = strfind(tablehirarchy, '#')

            if tablehirarchy[pos_deref+1] == '#'  # A gen id may follow
                continue

            pos_next_table_name = strfind(tablehirarchy, '/', pos_deref)
            if pos_next_table_name == -1
                pos_next_table_name = strfind(tablehirarchy, '.', pos_deref)
            if pos_next_table_name == -1
                pos_next_table_name = tablehirarchy.length - 1
            
            deref_tbl = LookupRequest.get_table_id tablehirarchy[pos_deref+1..pos_next_table_name-1]
            replace_str = tablehirarchy[pos_deref..pos_next_table_name-1]

            tablehirarchy.replace(replace_str, deref_tbl)
        
        if strfindr(tablehirarchy, '.') > -1
            tablehirarchy = tablehirarchy[..strfindr(tablehirarchy, '.')-1]
        
        return tablehirarchy

    ## Often we want to lookup a field's value
    @lookup: (tablename, fieldnames, ds_cond = null) ->
        tabledir = path.Directory(dbiondb_config.db.tabledir + LookupRequest.dereference(tablename))
        if not tabledir.exists()
            return []
        
        if typeof(fieldnames) == []
            fieldnames_str = listtostr(fieldnames)
            lup_rq = LookupRequest(tablename + '.' + fieldnames_str + '|*||' + dbiondb_config.db.dbext + '|')
        else
            lup_rq = LookupRequest(tablename + '.' + fieldnames + '|*||' + dbiondb_config.db.dbext + '|')
        tabledir_contents = lup_rq.filter_dir_by_fileregex(tabledir)

        yml = [Yaml]
        for file in tabledir_contents
            fp = Path(file)

            # TODO: Extension handling
            fc = Yaml.read fp.absolute()

            if type(fieldnames) != []
                fieldnames = [fieldnames]
            
            # TODO: Eval conditional lookup
            if ds_cond isnt null and not ds_cond.eval()
                continue

            yml_current = new Yaml('')
            for fieldname in fieldnames
                yml_current[fieldname] = fc[fieldname]
            yml.push yml_current
    
        return yml

    eval: () ->
        lup_rq = LookupRequest.lookup(this['tablename'], this['fieldname'])
        # TODO: raise LookupError
        return lup_rq


