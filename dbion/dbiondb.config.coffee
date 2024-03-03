
dbion =
    path: './example'
    dbfilesext: '.dbion.yml'
    tablefilesext: '.tbl.json'
    tldbfile: '#{dbname}.' + db.dbfilesext
    debug: true

db =
    path: dbion.path + '/dbiondb'
    tabledir: dbion.path + '/db'
    linkerdir:  dbion.path + '/lc'
    # Can be yml, coffee, json. If your config is yaml, all coffee files will be treated as yaml.
    # If it is concluding functions in config, an exception is raised for the file and you are hallowed to switch the variable dbext to coffee
    # dbext: 'coffee'
    dbext: '.yml'
    restext: 'json'

    # If you use the functionality "functions" in your config, your database extension is not yaml anymore, you'll need the coffeescript latency
    # templating = (param) ->
    #    gold = 'gold'

jinja_configs =
    path: 'jinja'
    extension: 'yml'


