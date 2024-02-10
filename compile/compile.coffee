// @flow

require 'coffeescript/register'

CoffeeScript = require 'coffeescript'
fs = require 'fs'

read_file: (filepath) ->
    return fs.readFileSync filepath 'utf8'

compilestr: (srcstr) ->
  {js, v3SourceMap, sourceMap} = CoffeeScript.compile srcstr
  return js

compile: (filepath) ->
    file_content = read_file filepath
    return compilestr file_content
