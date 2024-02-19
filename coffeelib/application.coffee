
import { EventProcessor, EventQueueHandler } from './events.js'


class Application
    @config_default_values: () -> return {}

    constructor: (@req, @res, @config = Application.config_default_values()) ->
        @pathInfo = url.parse @req.url, true
        @eventQueueHandler = new EventQueueHandler(@config)
    
    process: (func, args...) ->
        if /^\/javascripts\//.test @pathinfo.pathname
            return new EventProcessor(@eventQueueHandler).process(func, args)
        return false