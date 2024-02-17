

import { Event, EventHandler } from '../coffeelib/event.js'
export { Event, EventHandler } from '../coffeelib/event.js'

import { Queue } from '../coffeelib/queue.js'
export { Queue } from '../coffeelib/queue.js'

import { File } from '../coffeelib/path.js'

import * as ejs from 'ejs'


class EjsHandler extends EventHandler
    constructor: (bivariateDict = {}) ->
        super(bivariateDict)
        @eventQueue = new Multiqueue(3)

    # Please modify and specialice in your own classes with `EjsHandler::pre = ->`
    pre: (event, html = '') ->
        if not event? or typeof(event) != Event
            return html
        
        return super.preDo event, html

    # Please modify and specialice in your own classes with `EjsHandler::after = ->`
    after: (event, html = '') ->
        if not event? or typeof(event) != Event
            return html
        
        return super.afterDo event, html


ejs_tmpl: (ejs_file, event, ejsh = new EjsHandler(event.queue()), encoding = 'utf8') ->
    # Read a *.ejs file and use it for further altering of html and html java- and coffeescript code
    fc = new File(ejs_file).read encoding

    # Now alter HTML with the pre-after-handler and alter it with ejs.
    html = ejsh.pre(event, fc)

    html = ejs.render(html, event.queue())
    
    html = ejsh.after(event, html)

    # Return the resulting html
    return html

