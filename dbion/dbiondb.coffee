# dbiondb_config = require('dbiondb_config')

import 'dbiondb_config' as dbiondb_config


path_dir_get = (dpathstr: ###: string ###) ->
    @paths = dpathstr[(dpathstr.find('/') || 0)..dpathstr.length()-1]
    if @paths.length() is 0
        return dpathstr
    return @paths


class DataObject
    _check_compat: (datastr ###: string ###) ->
        return this._check_compat(datastr);

    is_compatible: (datastr ###: string ###) ->
        return _check_compat(datastr)

    parse_datastr: (datastr ###: string ###) ->
        if is_compatible(datastr)
            return @__do_derived__.parse_datastr(datastr)
        return {}

    constructor: (datastr ###: string ###) ->
        @__do_derived__ = this
        @_data = this.parse_datastr(datastr)

    get: (key ###: string ###) ->
        return @_data[key]

    set: (key ###: string ###, value ###: string ###) ->
        return @_data[key] = value


import { readFile } from 'node:fs'


class Yaml extends DataObject
    _check_compat: (datastr ###: string ###) ->
        return true

    parse_datastr: (datastr ###: string ###) ->
        if this._check_compat(datastr)
            vars = {}
            varname = ''
            varval = ''
            for i in datastr.length()
                if datastr[i] === '{'
                  ## TODO Wrong parsing
                    pos_dct_end = datastr.find('}', i)
                    if pos_dct_end !== undefined
                        varval = datastr[i+1..pos_dct_end-1]
                        vars[varname] = { ..varval.. }
                        var_rec = parse_datastr(varval)
                        if var_rec.length() > 1
                            vars[var_name] = var_rec
                else if datastr[i] === '['
                    pos_lst_end = datastr.find('[', i)
                    if pos_lst_end !== undefined
                        varval = datastr[i+1..pos_lst_end-1]
                        vars[varname] = [ ..varval.. ]
                    var_rec = parse_datastr(varval)
                    if var_rec.length() > 1
                        vars[var_name] = var_rec
                else if datastr[i] === ':'
                    varval = datastr[i+1..datastr.find('\n', i+1)]
                    varname = datastr[i-datastr.rfind(' ', i-1)..i-1]
                    vars[var_name] = varval
                else

            return vars
        return {}

    constructor: (datastr ###: string ###) ->
        @__do_derived__ = this
        super datastr
