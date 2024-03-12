

import { Multiqueue, BFS } from './queue.js'


class Event
    # A class using this could implement a Event.Reflector
    class Reflector
        startEvent: () => return false # DO something
        answerEvent: () => return true

    ## This function can be edited inlinely with `Event::eventFunctionality = ->` and is also called from the constructor
    # Class:: means always the prototype of a class, e.g. `Event.prototype.*`, while ``=>` makes property-like things.
    ## For more information have a look at https://coffeescript.org/#prototypal-inheritance and above
    eventFunctionality: (configuration = @configuration) ->
        # Do something with the objects from multiQueue
        if this.testIntegrity()
            # Run some event functions
            yield true
        yield false
    
    ## Can be evaluated and used with an inline- or lambda-like function and then called like:
    # e = Event({data: "Some test data"})
    # e.eventFunction((m) => {
    #       console.log m.data
    # }, BFS() )
    eventFunction: (func, configuration = @configuration) ->
        return func(multiQueue)

    # Can also get a json- or yml-like `{}` or a multiqueue from queue.coffee
    constructor: (@configuration = { eventType: 'BaseEvent' }) ->
    
    ## Like the function `eventFunctionality` this function can be specialized with `Event::testIntegrity = ->`
    testIntegrity: () =>
        return true
    
    config: () ->
        return @configuration


class EventHandler
    ## All this functions can be modified with `EventHandler.Private::func_name = ->`
    class Private
        @pre_handler_before(event, param = '') ->
            if not event? or typeof(event) != Event
                return false
            # You can specialize this e.g. with `return event.eventFunctionality(@eventQueue)`
            return event
        
        @pre_handler_after(event, param = '') ->
            if not event? or typeof(event) != Event
                return false
            return event
        
        @after_handler_before(event, param = '') ->
            if not event? or typeof(event) != Event
                return false
            return event
        
        @after_handler_after(event, param = '') ->
            if not event? or typeof(event) != Event
                return false
            return event

    constructor: (@options = {}) ->
        @eventQueue = new Multiqueue(3)

    preDo: (event, param='') -> return event
    afterDo: (event, param='') -> return event

    # Please modify and specialize in your own classes with `EventHandler::preDo = ->` or `EventHandler::pre = ->`
    pre: (event, param = '') ->
        if not event?
            return param
        @eventQueue = event.queue()

        # DO SOMETHING BEFORE DOING `ejs.render`
        Private.pre_handler_before event, param
        this.preDo event, param
        Private.pre_handler_after event, param
        
        return event

    # Please modify and specialize in your own classes with `EventHandler::afterDo = ->` or `EventHandler::after = ->`
    after: (event, param = '') ->
        if not event?
            return param
        @eventQueue = event.queue()

        # DO SOMETHING AFTER DOING `ejs.render`
        Private.after_handler_before event, param
        this.afterDo event, param
        Private.after_handler_after event, param

        return event
    
    properties: () -> return @options


EventQueueHandlerProperties: {
    process_incoming: false
    queue: undefined
}


class EventQueueHandler
    constructor: (@opts = EventQueueHandlerProperties) ->
        @queue = opts.queue
    
    install_queue: (queue) ->
        @queue = queue


    process_now: (event, param, args...) ->
        this.pre_processing event, param, args
        retval = event.eventFunctionality()
        this.after_processing event, param, args
        return retval

    push: (event) ->
        event = this.pre_push event, 'push'
        @queue.push event
        this.after_push event, 'push'
        return event

    pop: () ->
        try
            this.pre_pop undefined, 'pop'
        catch Error
            return undefined
        event = @queue.pop()
        event = this.after_pop event, event
        return event

    pre_push: (event, param = '') ->
        if @bivariateDict.process_incoming
            return this.process_now event, param
    
    after_push: (event, param = '') ->
    
    pre_pop: (event, param = '') ->
    
    after_pop: (event, element) ->
        return element
    
    pre_processing: (event, param = '') -> return true
    pre_processing: (event, func, args...) ->
        return true
    
    after_processing: (event, param = '') -> return true
    after_processing: (event, func, args...) ->
        return true


class EventProcessStarter extends Event
    constructor: (event_queue_handler, @event_processor) ->
        super(event_queue_handler)

    eventFunctionality() ->
        @event_processor.process()


EventProcessorProperties: EventQueueHandlerProperties + {
    process_after_push: false
    process_start_event: EventProcessStarterEvent | null
}


class EventProcessor extends BFS
    constructor: (@queue_handler = EventQueueHandler(EventProcessorProperties), queue_count = 3, queue_main_length = 4) ->
        super(3, 4)
    
    push: (event) ->
        @queue_handler.pre_push event
        super.push event
        if @queue_handler.properties().process_after_push
            this.process event.eventFunction, @queue_handler
        else if typeof(@queue_handler.properties().process_start_event) is typeof(event)
            event.eventFunctionality(this)
        return @queue_handler.after_push event
    
    pop: (event) ->
        @queue_handler.pre_pop event
        elem = super.pop()
        elem = @queue_handler.after_pop event, elem
        return elem
    
    process: (func, args...) ->
        while @queue_handler.hasElem()
            event = @queue_handler.pop()
            @queue_handler.pre_processing event, func, args
            retval = func(args)
            @queue_handler.after_processing event, func, args
        return [retval, this, func, args]
