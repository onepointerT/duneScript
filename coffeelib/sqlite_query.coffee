

SqliteQueryProperties: {
    select: ''
    from: ''
    where: ''
}


sqlite_query_props: (select, wherefrom, where = '') ->
    props = SqliteQueryProperties()
    props.select = select
    props.from = wherefrom
    props.where = where
    return props


sqlite_query_props_to: (select, whereto) ->
    props = SqliteQueryProperties()
    props.select = select
    props.into = whereto
    props.from = whereto
    return props


import { File } from './path'

class SqliteQuery
    constructor: (select, wherefrom = '', where = '') ->
        if typeof select is SqliteQueryProperties
            @query = select
        else if typeof select is Path
            fd = new path.File statement_or_file
            if fd.exists() and fd.is_file()
                # Do whatever to do with a file
                statement_or_file = fd.readSync()
        
        # Do whatever to do with a query statement
        pos_select_ends = strfind(statement_or_file, ' SELECT ') + 8
        pos_from_ends = strfind(statement_or_file, ' FROM ') + 6
        pos_where_ends = strfind(statement_or_file, ' WHERE ') + 7
        pos_into_ends = strfind(statement_or_file, ' INTO ') + 6

        no_where = false
        if pos_select_ends < 0
            return false
        else if pos_where_ends < 0
            no_where = true
        
        no_from = false
        if pos_from_ends < 0
            no_from = true
        
        no_into = true
        if pos_into_ends > 0
            no_into = false
        
        if no_where
            if not no_into
                select = statement_or_file[pos_select_ends..pos_into_ends-7]
                whereinto = statement_or_file[pos_into_ends..]
                @query = sqlite_query_props_to select, whereinto
            else if not no_from
                select = statement_or_file[pos_select_ends..pos_from_ends-7]
                wherefrom = statement_or_file[pos_from_ends..]
                @query = sqlite_query_props select, wherefrom
            else
                return false
        else
            wherefrom = statement_or_file[pos_from_ends..pos_where_ends-8]
            where = statement_or_file[pos_where_ends..]
            @query = sqlite_query_props select, wherefrom, where
    

    get: () -> return @query
    db: () => return {}
    db: (content) =>
    todb: (content) -> return this.db content
