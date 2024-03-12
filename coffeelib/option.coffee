

class OptionList extends []
    constructor: () -> super()

    class Template extends []
        constructor: (optionstrs = []) -> super(optionstrs)
    
    setOptionTemplate: (option_template) ->
        this.reset()
        for option in option_template
            this.push option


class Option extends {}
    constructor: () -> super()

    toOptionList: () ->
        optl = new OptionList
        for key, value in this
            optl.push value
        return optl

    class Template extends {}
        constructor: (optionstrs = {}) -> super(optionstrs)

    setOptionTemplate: (option_template) ->
        this.reset()
        is_optlist = if typeof options is [] then true else false
        if is_optlist
            for opt in options
                this[opt] = ''
        else
            for opt_key, opt in options
                this[opt_key] = opt
