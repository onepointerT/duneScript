require 'coffeescript/register'

App = require './app_exemplar'

CoffeeScript = require 'coffeescript'
fs = require 'fs'

read_file: (filepath) ->
  return fs.readFileSync filepath 'utf8'

compilestr: (srcstr) ->
  {js, v3SourceMap, sourceMap} = CoffeeScript.compile srcstr
  return js

compile: (filepath) ->
  return compilestr(filepath)
