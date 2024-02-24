
import { Engine } from '../coffeelib/engine'
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
        doctype: 'jade'
    }

    constructor: () ->
        super('jinja')
        @engineProperties = JinjaEngine.EngineProperties

    render: (fpath, paramDict) ->
        @engineProperties.filename = fpath.basename()
        return coffeec.run fpath, paramDict

    render_now: (content, paramDict) =>
        return content