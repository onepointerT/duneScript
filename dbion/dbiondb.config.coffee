
dbion =
    path: './examples/dbion'
    tldbfile: 'dbion.yml'

db =
    path: 'dbion'
    linkerdir: dbion.path + '/db'
    # Can be yaml, coffee, json. If your config is yaml, all coffee files will be treated as yaml.
    # If it is concluding functions in config, an exception is raised for the file and you are hallowed to switch the variable dbext to coffee
    dbext: 'coffee'
    restext: 'json'

    # If you use the functionality "functions" in your config, your database extension is not yaml anymore, you'll need the coffeescript launcher
    # templating = (param) ->
    #    gold = 'gold'

jinja_configs =
    path: 'jinja'
    extension: 'yml'


