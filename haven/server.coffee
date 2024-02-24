
import Application from '../coffeelib/application'
import * as event from '../coffeelib/event'
import genuuidv4 from '../coffeelib/str'
import Pair from '../coffeelib/tuple'

path = require('path')
global.express = require('express')
global.app_express = app_express = express()
require('#{dirname}/configuration')

global.cookieParser = cookieParser = require('cookie-parser')
global.createError = createError = require('http-errors')
global.logger = log = logger = require('morgan')


class ServerApplication extends Application
    ServerProperties: {
        host: '127.0.0.1'
        port: '7000'
    }
    RouterProperties: {
        siteContext: ''
        mergeParametersOfParent: false
        strictRouter: false
    }
    EventHandlerProperties: {
        process_incoming: false
        process_start_event: null
    }

    @config_default_values: () ->
        app_express.set('views', path.join(__dirname, 'views'))
        app_express.set('view engine', 'jade')

        app_express.use(express.bodyParser())
        app_express.use(express.methodOverride())
        app_express.use(cookieParser | express.cookieParser())
        app_express.use(express.urlencoded(extended: false))
        app_express.use(express.session(secret: genuuidv4().replace('-', '')))
        app_express.use(express.static(path.join(__dirname, 'public'), express.static))
        app_express.use(app_express.router)
        app_express.use(createError | express.errorHandler(dumpExceptions: true, showStack: true))

        return Application.ApplicationProperties + {
            server: ServerApplication.ServerProperties
            router: ServerApplication.RouterProperties
            event_handler: ServerApplication.EventHandlerProperties
        }
    
    
    class ExpressRouter extends express.Router
        constructor: ( routerParams = RouterProperties  ) ->
            super({ mergeParams: routerParams.mergeParametersOfParent, strict: routerParams.strictRouter })
            @siteContext = routerParams.siteContext
    
    class Endpoint extends Pair
        constructor: (endpoint_url = '/', router_module = new ExpressRouter()) ->
            super(endpoint_url, router_module)
        
        endpoint: () -> return @first
        router: () -> return @second


    @endpointList = [Endpoint]
    @routerList = [[ExpressRouter]]

    register_endpoint: (endpoint_url, router_module) ->
        endpoint = new Endpoint endpoint_url, router_module
        @endpointList.push endpoint
        return endpoint
    
    register_router: (view_name, router) ->
        @routerList.push [view_name, router]
        return router
    
    ep: (endpoint_url, router_module) ->
        return this.register_endpoint endpoint_url, router_module

    router: (view_name, router = null) ->
        if router?
            return this.register_router view_name, router
        return 
    
    get_ep: (endpoint_url) ->
        return endpoint for endpoint in @endpointList when endpoint.endpoint() is endpoint_url
        return this.ep endpoint_url, new Endpoint(endpoint_url, new ExpressRouter())
    
    get_router: (view_name) ->
        return router for viewstr, router in @routerList when viewstr is view_name
        return this.register_router view_name, new ExpressRouter()

    get: (endpoint_url, func) ->
        return (this.get_ep endpoint_url).router().get endpoint_url, func
    
    use: (req, res, nextFunc) ->
        if funcRetval = nextFunc(req, res) isnt true then return this.use_err funcRetval, req, res, nextFunc else return funcRetval

    use_err: (err, req, res, nextFunc) ->
        super.use (err, req, res) =>
            res.locals.message err.message
            res.locals.error = if req.app.get('env') == 'development' then err else {}

            if res.locals.error.length > 0
                res.status err.status or 500
                res.render 'error'
        

    class ServerEventQueueHandler extends event.EventQueueHandler
        constructor: (@eventHandlerProperties = EventHandlerProperties) ->
            super(@eventHandlerProperties)

    class ServerEventProcessor extends event.EventProcessor
        constructor: () ->
            super(new ServerEventQueueHandler(EventQueueHandlerProperties), 4, 5)


    Application.ApplicationEvent::eventFunction = ->
        if typeof(multiQueue) is typof(ServerApplication.ServerEventProcessor)
            return func(multiQueue)

    constructor: () ->
        super(express.Request(), express.Response(), ServerEventQueueHandler, this.config_default_values())
