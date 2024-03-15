

import { SyntaxDocument } from './syntax_document'
import { Condition } from '../conditional'


class SyntaxExpression extends {}
    full: ''
    previous: undefined
    body: ''
    next: undefined
    type: ''
    cond: undefined
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
    
    # Write and read variable from and to env.globals;
    # find out properties like type, delimiter, condition etc.
    alyze: (env) =>
    # Do things
    run: (env) =>
    # Immediatly return, if expr is undefined.
    # If defined, do things with a specialized expression
    run: (env, expr) =>
    # Finally do things with the environment like writing rest
    # of variables etc.
    finalyze: (env) =>