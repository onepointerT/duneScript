
class Node extends {}
    Type:
        Generic: 'generic'

    defaults: () =>
        this.reset()
        # In a script or an inheriting node class we could use a set of default values

    @tt = Node.Type
    @t = ''

    constructor: (classtype = Type.Generic) ->
        super()
        @t = classtype
        defaults()
        