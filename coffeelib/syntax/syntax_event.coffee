
import { Event, EventHandler } from '../event'
import { Queue } from '../queue'


SyntaxEventHandlerConfig = {
    debug: true
}


class SyntaxEvent extends Event
    constructor: () ->
        super(new Queue())

    eventFunctionality: (syntax_node) => return true
    eventFunction(func, syntax_node) => return func(syntax_node)


class SyntaxEventHandler extends EventHandler
    constructor: (@node, config = SyntaxEventHandlerConfig) ->
        super(config)
    
    setNode: (node) -> @node = node

    preDo: (syntax_event) =>
    afterDo: (syntax_event) =>