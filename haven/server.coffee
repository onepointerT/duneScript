
import Application from '../coffeelib/application'
import * as event from '../coffeelib/event'
import { File } from '../coffeelib/path'
import genuuidv4 from '../coffeelib/str'
import Pair from '../coffeelib/tuple'

path = require('path')
global.express = require('express')
global.app_express = app_express = express()
require('#{dirname}/configuration')

global.cookieParser = cookieParser = require('cookie-parser')
global.createError = createError = require('http-errors')
global.logger = logger = require('morgan')


class ServerApplication extends Application
    ServerProperties: {
        host: '127.0.0.1'
        port: '7000'
        router_class: ExpressRouter
        endpoint_class: Endpoint
    }

    classRouter: () ->
        return typeof(@config['server']['router_class'])
    
    classEndpoint: () ->
        return typeof(@config['server']['endpoint_class'])

    RouterProperties: {
        siteContext: ''
        mergeParametersOfParent: false
        strictRouter: false
        view_directory: '../views'
    }
    EventHandlerProperties: {
        process_incoming: false
        process_start_event: null
    }

    @config_default_values: () ->
        app_express.set('views', path.join(__dirname, 'views'))
        app_express.set('view engine', 'jade')
        app_express.use(require('connect-assets')())
        app_express.use(express.bodyParser())
        app_express.use(express.methodOverride())
        app_express.use(cookieParser | express.cookieParser())
        app_express.use(express.urlencoded(extended: false))
        app_express.use(express.json())
        app_express.use(express.session(secret: genuuidv4().replace('-', '')))
        app_express.use(express.static(path.join(__dirname, 'public'), express.static))
        app_express.use(app_express.router)
        app_express.use(logger('dev'))
        app_express.use(createError | express.errorHandler(dumpExceptions: true, showStack: true))

        return Application.ApplicationProperties + {
            server: ServerApplication.ServerProperties
            router: ServerApplication.RouterProperties
            event_handler: ServerApplication.EventHandlerProperties
        }
    
    
    class ExpressRouter extends express.Router
        constructor: ( @routerParams = RouterProperties  ) ->
            super({ mergeParams: routerParams.mergeParametersOfParent, strict: routerParams.strictRouter })
            @site_context = routerParams.siteContext
        
        getFileContent: () ->
            fn = @routerParams.view_directory + '/' + @site_context
            fd = new File fn + '.jinja'
            if fd.exists()
                return fd.readSync()
            fd = new File fn + '.jade'
            if fd.exists()
                return fd.readSync()
            fd = new File fn + '.html'
            if fd.exists()
                return fd.readSync()
            return ''
        
        siteContext: () -> return @site_context
        properties: () -> return @routerParams
    
    class Endpoint extends Pair
        constructor: (endpoint_url = '/', router_module = new ExpressRouter()) ->
            super(endpoint_url, router_module)
        
        endpoint: () -> return @first
        router: () -> return @second


    @endpointList = [classEndpoint()]
    @routerList = [[classRouter()]]

    register_endpoint: (endpoint_url, router_module) ->
        endpoint = new classEndpoint() endpoint_url, router_module
        @endpointList.push endpoint
        return endpoint
    
    register_router: (view_name, router) ->
        @routerList.push [view_name, router]
        return router
    
    ep: (endpoint_url, router_module) ->
        return this.register_endpoint endpoint_url, router_module
    
    endpoint: (endpoint_path, view_name) ->
        router = new classRouter()()
        register_endpoint endpoint_path, router
        register_router view_name, router

    router: (view_name, router = null) ->
        if router?
            return this.register_router view_name, router
        return 
    
    get_ep: (endpoint_url) ->
        return endpoint for endpoint in @endpointList when endpoint.endpoint() is endpoint_url
        return this.ep endpoint_url, new classRouter()(endpoint_url, new ExpressRouter())
    
    get_router: (view_name) ->
        return router for viewstr, router in @routerList when viewstr is view_name
        return this.register_router view_name, new classEndpoint()()

    get: (endpoint_url, func) ->
        return (this.get_ep endpoint_url).router().get endpoint_url, func
    
    use: (req, res, nextFunc) ->
        if funcRetval = nextFunc(req, res) isnt true then return this.use_err funcRetval, req, res, nextFunc else return funcRetval

    use_err: (err, req, res, nextFunc) ->
        app_express.use (err, req, res) ->
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


import { HtmlEngine } from './html_engine'

class HtmlRouter extends ServerApplication.ExpressRouter
    constructor: (site_context) ->
        routerProps = ServerApplication.RouterProperties + {
            siteContext: site_context
        }
        super(routerProps)
        @htmleng = new HtmlEngine()
    
    html: (paramDict) ->
        content = super.getFileContent()
        return @htmleng.render_now content, paramDict


class HtmlEndpoint extends ServerApplication.Endpoint
    constructor: (endpoint_path, view_name) ->
        htmlr = new HtmlRouter view_name
        super(endpoint_path, htmlr)
    
    html: () ->
        return router.html()


class HtmlServer extends ServerApplication
    @config_default_values: () ->
        return super.config_default_values() + {
            server: {
                router_class: HtmlRouter
                endpoint_class: HtmlEndpoint
            }
        }

    constructor: () ->
        super()

