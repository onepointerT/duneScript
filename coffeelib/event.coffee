

import { Multiqueue, BFS } from './queue.js'


class Event
    ## This function can be edited inlinely with `Event::eventFunctionality = ->` and is also called from the constructor
    # Class:: means always the prototype of a class, e.g. `Event.prototype.*`, while ``=>` makes property-like things.
    ## For more information have a look at https://coffeescript.org/#prototypal-inheritance and above
    eventFunctionality: (multiQueue = @multiQueue) ->
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
    eventFunction: (func, multiQueue = @multiQueue) ->
        return func(multiQueue)

    # Can also get a json- or yml-like `{}` or a multiqueue from queue.coffee
    constructor: (@multiQueue = {}) ->
    
    ## Like the function `eventFunctionality` this function can be specialized with `Event::testIntegrity = ->`
    testIntegrity: () ->
        return true

    push: (elem) ->
        @multiQueue.push elem
    
    pushMulti: (elems) ->
        @multiQueue.pushMulti elems
    
    pop: () ->
        return @multiQueue.pop()
    
    queue: () ->
        return @multiQueue


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

    constructor: (@bivariateDict = {}) ->
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
            return html
        @eventQueue = event.queue()

        # DO SOMETHING AFTER DOING `ejs.render`
        Private.after_handler_before event, param
        this.afterDo event, param
        Private.after_handler_after event, param

        return event
