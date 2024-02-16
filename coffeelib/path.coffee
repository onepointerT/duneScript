
fs = require 'fs'
path = require('node:path')


export class Path
    constructor: (@path) ->

    basename: () ->
        return path.basename @path

    dirname: () ->
        return path.dirname @path
    
    extname: () ->
        return path.extname @path
    
    format: (dct = {}) ->
        return path.format dct
    
    is_absolute: () ->
        return path.isAbsolute @path
    
    stats: () ->
        return fs.stat @path
    
    is_dir: () ->
        return extname().length is 0

    is_file: () ->
        return extname().length > 0

    join: (pathstr) ->
        return path.join [@path, pathstr]

    join: (paths) ->
        return path.join paths

    normalize: () ->
        return path.normalize @path
    
    parse: () ->
        return path.parse @path
    
    relative: (pathTo) ->
        return path.relative @path pathTo
    
    absolute: () ->
        return path.resolve @path
    
    set: (path) ->
        @path = path

    get: () ->
        return @path


import { open, opendir } from 'node:fs/promises'


export class Directory extends Path
    constructor: (path) ->
        super path
    
    getEntries: () ->
        if not is_dir
            return []
        dir_entries = []
        dir = await opendir(@path);
        for dirent in dir
            dir_entries.push dirent
        return dir_entries
    
    getEntriesByRegex: (regex) ->
        dir_entries = this.getEntries
        regexp = new RegExp(regex)
        matches = []
        for dir_entry in dir_entries
            if regex.test(dir_entry.basename())
                matches.push dir_entry
        return matches
    
    getDirectories: () ->
        dir_entries = this.getEntries
        dir_dirs = []
        for dirent in dir_entries
            path = Path(dirent)
            if path.is_dir
                dir_dirs.push dirent
        return dir_dirs
    
    getFiles: () ->
        dir_entries = this.getEntries
        dir_files = []
        for dirent in dir_entries
            path = Path(dirent)
            if path.is_file
                dir_files.push dirent
        return dir_files



export class File extends Path
    constructor: (path) ->
        super path
    
    readSync: () ->
        fd = await open @path 'r'
        return fd.createReadStream
    
    writeSync: (data) ->
        fd = await open @path 'w'
        return fd.createWriteStream data

    read: (encoding = 'utf8') ->
        return readSync encoding

    write: (data, encoding = 'utf8') ->
        return writeSync data encoding
