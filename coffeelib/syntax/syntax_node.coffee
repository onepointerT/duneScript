
import Node from '../node'

class SyntaxNode extends Node
    Type =  Node.Type +=
        Syntax: 'syntax'
    
    defaults: () =>
        id: ''
        body: ''
        left: ''
        right: ''
        precending: undefined
        following: undefined
        code: left + body + right
    
    constructor: (classtype = Type.Syntax) ->
        super(classtype)
        defaults()
    
    setPrecending: (syntax_node) ->
        precending = syntax_node
        return this

    setFollowing: (syntax_node) ->
        following = syntax_node
        return this
    
    toString: () -> return '#{code}'


    class Equivalence extends Node
        Type = SyntaxNode.Type +=
            SyntaxEquivalent: 'syntax_equivalent'
        
        constructor: (syntax_node, syntax_node2, name) ->
            super(SyntaxNode)
            @id = name
            @body1 = syntax_node.body
            @left1 = syntax_node.left
            @right1 = syntax_node.right
            @body2 = syntax_node2.body
            @left2 = syntax_node2.left
            @right2 = syntax_node2.right
        
        toString: () -> return """
            ----
            #{left1}#{body1}#{right1}
            ----
            #{left2}#{body2}#{right2}"""
