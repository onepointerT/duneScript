
import { CodeDocument } from '../coffee1lib/syntax/code_document'
import { SyntaxExpression } from '../coffee1lib/syntax/syntax_expression'
import { SyntaxNode } from '../coffeelib/syntax/syntax_node'
import { Tag as BaseTag, makeTag } from '../coffeelib/tag'


class Jinja extends CodeDocument
    class Format extends CodeDocument.Format
        DataTypes =  CodeDocument.Format.DataTypes +=
            Html: 'html'
            Script: 'script'
            Ejs: 'ejs'

    
    class Tag extends CodeDocument.Tag
        Type = CodeDocument.Tag.Type +=
            Html: 'html'

        detectType: () =>
            super.detectType()
        
        constructor: (content, delim_left, delim_right) ->
            super(content, delim_left, delim_right)

    tags: [Jinja.Tag]
    tag: undefined

    register_formats: () =>
        super.register_formats()
        
        # Register basic jinja syntax and delimiters
        delim_syntax_expr = new SyntaxDocument.Format.Delimiter 'expression', '{% ', ' %}'
        delim_variable_expr = new SyntaxDocument.Format.Delimiter 'var_expression', '{{ ', ' }}'
        delim_ejs_expr = new SyntaxDocument.Format.Delimiter 'ejs_expression', '<%= ', ' =%>'
        jinja_format = Jinja.Format '', Jinja.Format.DataTypes, '</html>'
        jinja_format.register_delimiter delim_syntax_expr
        jinja_format.register_delimiter delim_variable_expr
        jinja_format.register_delimiter delim_ejs_expr
        @formats.push jinja_format

        # Register syntactic if
        delim_if = new Jinja.Format.Delimiter 'if', '{% if ', '{% endif %}'
        jinja_if = new Jinja.Format '', Jinja.Format.DataTypes.If, '{% endif %}'
        jinja_if.register_delimiter delim_if
        @formats.push jinja_if

        # Register syntactic for
        delim_for = new Jinja.Format.Delimiter 'for', '{% for ', '{% endfor %}'
        jinja_for = new Jinja.Format '', Jinja.Format.DataTypes.For, '{% endfor %}'
        jinja_for.register_delimiter delim_for
        @formats.push jinja_for

        # Register syntax setvar
        delim_set = new Jinja.Format.Delimiter 'set', '{% set ', ' %}'
        jinja_set = new Jinja.Format '', Jinja.Format.DataTypes.SetVar, ' %}'
        jinja_set.register_delimiter delim_set
        @formats.push jinja_set

        # Register syntactical include
        delim_include = new Jinja.Format.Delimiter 'include', '{% include ', ' %}'
        jinja_include = new Jinja.Format '', Jinja.Format.DataTypes.Include, ' %}'
        jinja_include.register_delimiter delim_include
        @formats.push jinja_include

        # Register syntactical import
        delim_import = new Jinja.Format.Delimiter 'import', '{% import ', ' %}'
        jinja_import = new Jinja.Format '', Jinja.Format.DataTypes.Import, ' %}'
        jinja_import.register_delimiter delim_import
        @formats.push jinja_import

        # Register syntactic macro
        delim_macro = new Jinja.Format.Delimiter 'macro', '{% macro ', '{% endmacro %}'
        jinja_macro = new Jinja.Format '', Jinja.Format.DataTypes.Macro, '{% endmacro %}'
        jinja_macro.register_delimiter delim_macro
        @formats.push jinja_macro

        # Register syntax for html
        opening = new Format.Delimiter 'opening', '<', '>'
        closing = new Format.Delimiter 'closing,', '</', '>'
        html_format = new Format '', Jinja.Format.DataTypes.Html, '</$starttag>'
        html_format.register_delimiter opening
        html_format.register_delimiter closing
        @formats.push html_format

    constructor: (full_document = '') ->
        super(full_document)
        this.register_formats()