
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
        
        expr: undefined
        expressions: {}

        register_expression: (name, expression) ->
            expressions[name] = expression

        choose_expression: (name) ->
            this.expr = this.expressions[name]
        
        use_here: (env, element) ->
            env.element = element
            if this.expr?
                this.expr.alyze env
                this.expr.run env
                this.expr.run env, this.expressions[env.type]
                this.expr.finalyze env
            return env

        use: (env, element) ->
            # TODO Find the right expression for the current element
            return use_here env, element

        constructor: (expression, data_type, delim_end) ->
            super '', data_type, delim_end
            @expr = expression

    
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

        expr: undefined

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
        
        constructor: (content, delim_left, delim_right, expr) ->
            super(content, delim_left, delim_right)
            detectType()

    tags: [CodeDocument.Tag]
    tag: undefined

    block +=
        delimiter: undefined

        makeTag: () ->
        
        find_block_end: () ->

        # In a generic code document we can at least find the block ranges
        # by identation level
        detect_blocks_code: () ->
            this.whitespaces.reset()
            this.whitespaces.next_newline()
            return this.block.detect_blocks new Range 0, this.full.length, this.full



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
