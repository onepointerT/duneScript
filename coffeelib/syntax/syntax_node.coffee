
import Node from '../node'

class SyntaxNode extends Node
    Type = Node.Type +=
        Syntax: 'syntax'
    
    defaults: () =>
        id: ''
        body: ''
        left: ''
        right: ''
        precedending: ''
        following: ''
        code: ''
    
    constructor: (classtype = Type.Syntax) ->
        super(classtype)
        defaults()
    
