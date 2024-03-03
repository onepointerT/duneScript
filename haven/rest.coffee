

_ = require('lodash')

class Request extends {}
    constructor: () ->
        super()

    post: (app, endpoint, field = '') ->
        return app.post endpoint, this[field]
        
    get: (app, endpoint) ->
        this['response'] = app.get endpoint
        this['response_time'] = _.now()
        return this['response']


class Response extends Request
    constructor: () ->
        super()

    got: (app, field = '') ->
        this['response_now'] = app.listenedEvent()
        this['response_now_time'] = _.now()
        this[field] = this['response_now']
    
    push: (app, endpoint, field = '') ->
        app.push endpoint, this[field]
