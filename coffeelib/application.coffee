
import { Event, EventProcessor, EventProcessorProperties, EventQueueHandler, EventQueueHandlerProperties } from './event'


class Application extends EventProcessor
    class ApplicationEvent extends Event
        constructor: (multiQueue, @obj = null) ->
            super(multiQueue)

    ApplicationProperties: {
        event_class: ApplicationEvent
        event_queue_handler: EventQueueHandlerProperties
        event_processor: EventProcessorProperties
    }

    @config_default_values: () -> return Application.ApplicationProperties + {}

    constructor: (@req, @res, @eventqueuehandlerclass, @config = Application.config_default_values()) ->
        @pathInfo = url.parse @req.url, true
        @eventQueueHandler = new type(@eventqueuehandlerclass)(@config['event_queue_handler'])
        super(@EventQueueHandler, 5)
    
    process: (func, args...) ->
        if /^\/javascripts\//.test @pathinfo.pathname
            return new EventProcessor(@eventQueueHandler).process(func, args)
        return false
    
    req: (request = null, args...) ->
        if request?
            super.push new Event
