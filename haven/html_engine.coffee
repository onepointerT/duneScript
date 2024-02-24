
import { Engine } from '../coffeelib/engine'
import { Directory, File } from '../coffeelib/path'
import strfind from '../coffeelib/str'
import { JadeEngine, JinjaEngine } from '../templating/engines'


class HtmlEngine extends Engine
    EngineProperties = Engine.EngineProperties + {
        doctype: 'html'
        tmpdir: new Directory('#{__dirname}/tmp')
        jade: JadeEngine.EngineProperties + {
            debug: true
        }
        jinja: JinjaEngine.EngineProperties + {
            debug: true
        }
    }

    constructor: (tmpdir = '#{__dirname}/tmp') ->
        super('html')
        @engineProperties = HtmlEngine.EngineProperties
        @engineProperties.tmpdir = new Directory(tmpdir)
    
    render_now: (content, paramDict) =>
        if strfind(content, '{%') > -1
            # We found jinja before using jade
            jine = new JinjaEngine()
            content = jine.render_now content, paramDict
        
        jae = new JadeEngine()
        html = jae.render_now content, paramDict
        
        if strfind(html, '{%') > -1
            # We found jinja in jade
            jine = new JinjaEngine()
            html = jine.render_now html, paramDict
        return html