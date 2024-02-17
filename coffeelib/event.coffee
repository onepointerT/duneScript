

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
        return True
    
    push: (elem) ->
        @multiQueue.push elem
    
    pop: () ->
        return @multiQueue.pop()
    
    queue: () ->
        return @multiQueue

