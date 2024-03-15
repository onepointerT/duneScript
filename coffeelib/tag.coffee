
import { SyntaxNode } from './syntax/syntax_node'


class Tag extends SyntaxNode
    Type = SyntaxNode.Type +=
        Tag: 'tag'
        SyntaxTag: 'syntax_tag'
    
    
    constructor: (content, delim_left, delim_right = delim_left, name = '') ->
        super(Tag.Type.SyntaxTag)
        @id = name
        @body = content
        @left = delim_left
        @right = delim_right


makeTag: (content, left, right = left, id = '') ->
    tag = new Tag content, left, right, id
    return tag
