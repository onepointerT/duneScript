

class Stack extends {}
    stacktype: 'generic'
        
    constructor: (type, {} = configuration)
        super()
        @stacktype = type
        if configuration.globals?
            @globals += configuration.globals
