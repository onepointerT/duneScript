

import { SyntaxDocument } from './syntax_document'
import { Condition } from '../conditional'


class SyntaxExpression extends {}
    full: ''
    previous: undefined
    body: ''
    next: undefined
    type: ''
    format: undefined
    delimiter: undefined

    constructor: (expr_type, expr_delimiter = undefined, expr_format = undefined) ->
        type = expr_type
        format = expr_format
        delimiter = expr_delimiter

    reset: () ->
        full = ''
        previous = undefined
        next = undefined