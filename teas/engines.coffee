
import { Engine } from '../coffeelib/engine'
import { Directory, File } from '../coffeelib/path'
import genid from '../coffeelib/str'
import { coffeec } from './jinjac'
jade = require('jade')


class JadeEngine extends Engine
    EngineProperties = Engine.EngineProperties + {
        doctype: 'jade'
        debug: false
    }

    constructor: () ->
        super('jade')
        @engineProperties = JadeEngine.EngineProperties

    render: (fpath, paramDict) ->
        @engineProperties.filename = fpath.basename()
        @engineProperties.globals = paramDict
        return (jade.compileFile fpath, @engineProperties)(paramDict)

    render_now: (content, paramDict) =>
        @engineProperties.globals = paramDict
        return (jade.compile content, @engineProperties)(paramDict)


class JinjaEngine extends Engine
    EngineProperties = Engine.EngineProperties + {
        doctype: 'jinja'
        tmpdir: new Directory('#{__dirname}/tmp')
    }

    constructor: (tmpdir = '#{__dirname}/tmp') ->
        super('jinja')
        @engineProperties = JinjaEngine.EngineProperties
        @engineProperties.tmpdir = new Directory(tmpdir)

    render: (fpath, paramDict) ->
        @engineProperties.filename = fpath.basename()
        # CoffeeC writes all jinja output to a file with the same name, adding an extension '.html'
        return coffeec.run fpath, paramDict

    render_now: (content, paramDict) =>
        if not @engineProperties.tmpdir.exists()
            @engineProperties.tmpdir.mkdir()
        fname = genid() + '.jinja'
        fd = new File @engineProperties.tmpdir + '/' + fname
        fd.writeSync content
        this.render fd.get(), paramDict
        # Read the generated '.jinja.html' file and return the html
        fd = new File @engineProperties.tmpdir + '/' + fname + '.html'
        return fd.readSync()