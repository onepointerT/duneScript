

import { Event } from '../coffeelib/event.js'
export { Event } from '../coffeelib/event.js'

import { Queue } from '../coffeelib/queue.js'
export { Queue } from '../coffeelib/queue.js'

import { File } from '../coffeelib/path.js'

import * as ejs from 'ejs'


class EjsHandler
    constructor: (@bivariateDict = {}) ->
        @eventQueue = new Multiqueue(3)

    # Please modify and specialice in your own classes with `EjsHandler::pre = ->`
    pre: (event, html = '') ->
        @eventQueue = event.queue()
        # DO SOMETHING BEFORE DOING `ejs.render`
        return html

    # Please modify and specialice in your own classes with `EjsHandler::pre = ->`
    after: (event, html = '') ->
        @eventQueue = event.queue()
        # DO SOMETHING AFTER DOING `ejs.render`
        return html


ejs_tmpl: (ejs_file, event, ejsh = new EjsHandler(event.queue()), encoding = 'utf8') ->
    # Read a *.ejs file and use it for further altering of html and html java- and coffeescript code
    fc = new File(ejs_file).read encoding

    # Now alter HTML with the pre-after-handler and alter it with ejs.
    html = ejsh.pre(event, fc)

    html = ejs.render(html, event.queue())
    
    html = ejsh.after(event, html)

    # Return the resulting html
    return html

