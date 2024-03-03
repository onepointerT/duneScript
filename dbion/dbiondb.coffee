import { stringify } from 'yaml/dist/stringify/stringify'
# dbiondb_config = require('dbiondb_config')

dbiondb_config = await require('./dbiondb.config')
import { Conditional } from '../coffeelib/conditional'
import * as path from '../coffeelib/path'
import { SqliteQuery, SqliteQueryProperties } from '../coffeelib/sqlite_query'
import { strfind, strfindr, strreplace, listtostr } from '../coffeelib/str'


path_dir_get: (dpathstr) ->
    paths = dpathstr[(dpathstr.find('/') || 0)..dpathstr.length()-1]
    if paths.length() is 0
        return dpathstr
    return paths



class BivariateDict extends {}
    @default_dict = {}

    @default_values: () ->
        return @default_dict
    
    constructor: ({} = default_dct) ->
        super(default_dct)
        @default_dict = default_dct
    
    reset: () ->
        super.clear()
        for key, value in default_values()
            this[key] = value


export class DataObj extends BivariateDict
    _check_compat: (datastr) ->
        return this._check_compat(datastr);

    is_compatible: (datastr) ->
        return _check_compat(datastr)

    parse_datastr: (datastr) ->
        return {};

    constructor: (datastr) ->
        data = parse_datastr datastr
        super(data)
        @data = data
        @extension = 'dbion'

    stringify: () => return '{}'

    get: (key) ->
        return @data[key]

    set: (key, value) ->
        return @data[key] = value

    setAll: (content = {}) ->
        for key, value in content
            if @data[key] isnt value
                @data[key] = value

    fromFile: (fpath) ->
        fd = new path.File fpath
        if fd.exists() and fd.is_file()
            content = fd.readSync()
            @data = this.parse_datastr content

    toFile: (fpath, content) ->
        fromFile fpath
        setAll content
        toFile fpath

    toFile: (fpath) ->
        fd = new path.File fpath
        fd.writeSync stringify @data 


import YAML, { Pair } from 'yaml'


export class Yaml extends DataObj
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
        if datastr.length > 2
            @data = parse_datastr datastr
        else if @filepath.length > 0
            @data = parse_file()
        else
            @data = this.default_values()
        @extension = 'yml'

    @write: (fpath, finput) ->
        file = new Yaml fpath finput
        file.write_file stringify()
        return file

    @read: (fpath) ->
        file = new Yaml fpath
        return file


yaml_list_merge: (yml_list) ->
    yml_merged_str = '-\n  '
    for yml in yml_list
        yml_merged_str += yml.stringify()
        yml_merged_str += '\n-\n  '
    return new Yaml '', yml_merged_str


import JSON5 from 'json5'

export class Json extends DataObj
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

    constructor: (@filepath, datastr = '') ->
        super datastr
        if datastr.length > 2
            @data = parse_datastr datastr
        else if @filepath.length > 0
            @data = parse_file()
        else
            @data = this.default_values()
        @extension = 'json'


class DataHandler extends DataObj
    @default_dict = {}
    @dataHandlerClass = Yaml
    @dataHandler = new Yaml()

    @default_values: () ->
        
    constructor: ({} = default_dct, data_handler_class_override = null) ->
        super('{}')
        
        if dbiondb_config.db.dbext is 'yml'
            data_handler_class = Yaml
        else if dbiondb_config.db.dbext is 'json'
            data_handler_class = Json
        else if data_handler_class_override isnt null
            data_handler_class = data_handler_class_override
            
        @dataHandlerClass = data_handler_class
        @default_dict = default_dct
        @dataHandler = new (typeof @dataHandlerClass)('{}')
    
    parse_datastr: (datastr) ->
        return @dataHandler.parse_datastr datastr
    
    get: (key) ->
        return @dataHandler.get key
    
    set: (key, value) ->
        return @dataHandler.set key, value
    
    setAll: (content = {}) ->
        return @dataHandler.setAll content
    
    stringify: () -> return @dataHandler.stringify()
    



export class FileHandler extends DataHandler
    constructor: ({} = default_dct, data_handler_class_override = null) ->
        if dbiondb_config.db.dbext is 'yml'
            data_handler_class = Yaml
        else if dbiondb_config.db.dbext is 'json'
            data_handler_class = Json
        else if data_handler_class_override isnt null
            data_handler_class = data_handler_class_override
        super(default_dct, data_handler_class)

    ds_write: (fpath, finput) ->
        return @dataHandler.write fpath finput
    
    ds_read: (fpath) ->
        return @dataHandler.read fpath
    
    ds_write: (table, dsid, dscontent) ->
        path = dbiondb_config.db.tabledir + '/' + table + '/' + dsid + '.' + dbiondb_config.db.dbext
        return this.ds_write path, dscontent
    
    ds_read: (table, dsid) ->
        path = dbiondb_config.db.tabledir + '/' + table + '/' + dsid + '.' + dbiondb_config.db.dbext
        return this.ds_read path

    tbl_read: (table) ->
        path = dbiondb_config.db.path + '/' + table + '.' + dbiondb_config.db.dbext
        return this.ds_read path
    
    tbl_write: (table, content) ->
        path = dbiondb_config.db.path + '/' + table + '.' + dbiondb_config.db.dbext
        # TODO Tell the event loop to update the database
        return this.ds_write path, content
    
    tbl_collect: ({name, fields, cond = '', joins = [...{}], extension = 'yml', token = gentoken()} = table) ->
        tabledef_path = new path.Path dbiondb_config.db.tabledir + '/' + table['name'] + dbiondb_config.dbion.tablefilesext
        return new (typeof @dataHandlerClass)(tabledef_path, '{}')

    db_read: (table) ->
        pathstr = dbiondb_config.db.path + '/' + table + '.' + dbiondb_config.db.dbext
        path = new path.File pathstr
        if not path.exists()
            this.tbl_collect table
            return path
    

class Variable extends BivariateDict
    @default_values: () ->
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
        cond: ''
        matchall: false
        fieldlist: []

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
gentoken: () -> genuuid()[23..]


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
        
        if typeof(fieldnames) is []
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

    ## Often we want to lookup a field's value
    @write: (tablename, ds_id, content) ->
        tabledir = path.Directory(dbiondb_config.db.tabledir + LookupRequest.dereference(tablename))
        if not tabledir.exists()
            return {}

        # TODO: Dereference table joins and write them to file
        # yml = [Yaml]
        fpath = tabledir + '/' + ds_id + '.' + dbiondb_config.db.dbext
        yml.toFile fpath, content
    
        return yml

    eval: () ->
        lup_rq = [typeof @dataHandlerClass]
        if this['fieldlist'].length > 1
            for field in fieldlist
                lup_rq.push LookupRequest.lookup(this['tablename'], field)
        else
            lup_rq.push LookupRequest.lookup(this['tablename'], this['fieldname'])
        # TODO: raise LookupError
        return lup_rq


class Query extends SqliteQuery
    constructor: (statement_or_file) ->
        super(statement_or_file)
    
    toDbionSyntax: () ->
        starmee = false
        if @query.where is ''
            starmee = true
        
        statement = ''
        if starmee
            statement += '*'
        
        statement += '$$'
        statement += @query.from
        statement += '.['
        statement += @query.select
        statement += ']'

        if starmee
            statement += '*'
        
        return statement

    db: () =>
        return LookupRequest.lookup(@config.from, @config.select)
    
    db: (content) =>
        return LookupRequest.write @config.from, content


class Table extends DataObject
    @ext = 'yml'
    @token = ''

    constructor: ({name, fields, cond = '', joins = [...{}], extension = 'yml', token = gentoken()} = table) ->
        super(table)
        if table['extension'] isnt @ext
            @ext = table['extension']
        if table['token'] isnt @token
            @token = table['token']
        @table = table
    
    table: () -> return @table
    
    @gen_tabledef: (tabledef) ->
        tabledef_path = new path.File dbiondb_config.db.tabledir + '/' + tabledef['name'] + dbiondb_config.db.dbfilesext
        # Update the tabledef that was found
        tabledef_path.writeSync tabledef.stringify()
        return this.read_tabledef tabledef['name']
        
    @gen_tabledef: (table, tabledef) ->
        tabledef_path = new path.File dbiondb_config.db.tabledir + '/' + table + dbiondb_config.dbion.tablefilesext
        tabledef = { name: tabledef.name, fields: tabledef.fields, cond: tabledef.cond, joins: if tabledef.joins? then tabledef.joins else [] }
        json = new Json '', tabledef
        json.toFile tabledef_path
        return json
        
    @read_tabledef: (table) ->
        tabledef_path = new path.File dbiondb_config.db.tabledir + '/' + table + dbiondb_config.dbion.tablefilesext
        json = new Json tabledef_path
        return json

    @read_tabledef: (dbname) ->
        tldbf_path = dbiondb_config.dbion.path + '/' + dbiondb_config.dbion.tldbfile
        dao = new Yaml tldbf_path
        tables = dao[dbname]['tables']
        tabledefs = dao[dbname]['tabledef']
        for tabledef in tabledefs
            this.gen_tabledef tabledef['name'], tabledef
        tabledef_list = {}
        for table in tables
            json = this.read_tabledef table
            tabledef_list[table] = json
        return tabledef_list
    
    tabledef_gen: (dbname) ->
        tabledef_path = new path.File dbiondb_config.db.tabledir + '/' + this.table()['name'] + dbiondb_config.dbion.tablefilesext
        if tabledef_path.exists()
            return true
        tabledef_list = Table.read_tabledef dbname
        return Table.gen_tabledef tabledef_list[this.table()['name']]
    
    tabledef_read: () ->
        tabledef_path = new path.File dbiondb_config.db.tabledir + '/' + table + dbiondb_config.dbion.tablefilesext
        if not tabledef_path.exists()
            Table.gen_tabledef table()
        return Table.read_tabledef table()['name']
    
    # Returns a tuple (intern, extern) table fields
    fieldlist_filter: () ->
        fieldlist = table()['fields']
        fieldlist_filtered_extern = []
        fieldlist_filtered_intern = []
        for field in fieldlist
            if strfind(field, '.') > -1  # There is a lookup or join from another table
                fieldlist_filtered_extern.push field
            else
                fieldlist_filtered_intern.push field
        return new Pair fieldlist_filtered_intern, fieldlist_filtered_extern
    
    @sort_extern_fields_by_table: () ->
        # TODO

    table_collect: () ->
        fieldlist_filtered = this.fieldlist_filter()
        
        this.reset()

        lup_rq = new LookupRequest '$$' + @table['name'] + '.[' + listtostr(fieldlist_filtered.first) + ']'
        yml_list = lup_rq.eval()
        yml = yaml_list_merge yml_list

        # TODO: Lookup extern joins

        dao_path = dbiondb_config.dbion.tabledir + '/' + @table['name'] + dbiondb_config.db.dbext
        return Yaml.write dao_path, yml.stringify()



DataHandler::tbl_collect = ->
    # TODO read table config
    # TODO set variable according to the fields
    # table = new Table
    # return table.table_collect()
        