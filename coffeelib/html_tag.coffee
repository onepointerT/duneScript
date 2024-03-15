import { html } from './parser/cheerio/lib/api/manipulation'

import { Document } from './document'
import { Tag } from './tag'


class HtmlTag extends Tag
    Type = Tag.Type +=
        HtmlTag: 'html_tag'
    
    
    constructor: (content, delim_left, delim_right = delim_left, name = '') ->
        super(content, delim_left, delim_right, name)
        @t = Type.HtmlTag
        @inner = undefined

    toHtml: () ->
        if inner?
            return """#{left}#{inner.toString()}#{right}"""
        return """#{code}"""


makeTag: (content, left, right = left, id = '') ->
    tag = new Tag content, left, right, id
    return tag



class HtmlDocument extends Document
    constructor: () ->
        super('')
        @html = new HtmlTag '', '<html>', '</html>'
        @body = new HtmlTag '', '<body>', '</body'
        @html.inner = @body
        @element = @html
    
    class Format extends Document.Format
        DataTypes:
            HtmlDocument: 'html_doc'
            HtmlTag: 'html_tag'
            HtmlGeneric: 'html_generic'

    register_formats: () =>
        opening = new Format.Delimiter 'opening', '<', '>'
        closing = new Format.Delimiter 'closing,', '</', '>'
        html_format = new Format '', HtmlDocument.Format.DataTypes, '</$starttag>'
        html_format.register_delimiter opening
        html_format.register_delimiter closing
        @formats.push html_format