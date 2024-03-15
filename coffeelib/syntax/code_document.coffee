
import { SyntaxDocument } from '../coffee1lib/syntax/syntax_document'
import { SyntaxExpression } from '../coffee1lib/syntax/syntax_expression'
import { SyntaxNode } from '../coffeelib/syntax/syntax_node'
import { Tag as BaseTag, makeTag } from '../coffeelib/tag'


class CodeDocument extends SyntaxDocument
    class Format extends SyntaxDocument.Format
        DataTypes =  SyntaxDocument.Format.DataTypes +=
            Code: 'code'
            CodeIf: 'code_if'
            CodeFor: 'code_for'
            CodeSet: 'code_set'

    
    class Tag extends BaseTag
        Type = BaseTag.Type +=
            If: 'if'
            IfElse: 'ifelse'
            IfElif: 'ifelif'
            For: 'for'
            ForAll: 'forall'
            Import: 'import'
            Include: 'include'
            SetVar: 'set'
            Macro: 'macro'
            Script: 'script'

        detectType: () =>
            if content[..1] is 'if'
                @t = Type.If
            else if content[..3] is 'elif' or content[..6] is 'else if'
                @t = Type.IfElif
            else if content[..3] is 'else'
                @t = Type.Else
            else if content[..2] is 'for'
                @t = Type.For
            else if content[..2] is 'set'
                @t = Type.SetVar
            else if content[..4] is 'macro'
                @t = Type.Macro
            else
                @t = Type.Script
        
        constructor: (content, delim_left, delim_right) ->
            super(content, delim_left, delim_right)
            detectType()

    tags: [CodeDocument.Tag]
    tag: undefined

    register_formats: () =>
        # Register syntactic if
        delim_if = new CodeDocument.Format.Delimiter 'if', 'if ', ''
        code_if = new CodeDocument.Format '', CodeDocument.Format.DataTypes.If, ''
        code_if.register_delimiter delim_if
        @formats.push code_if

        # Register syntactic for
        delim_for = new CodeDocument.Format.Delimiter 'for', 'for ', ''
        code_for = new CodeDocument.Format '', CodeDocument.Format.DataTypes.For, ''
        code_for.register_delimiter delim_for
        @formats.push code_for

    constructor: (full_document = '') ->
        super(full_document)