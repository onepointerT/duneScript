
import Document from '../document'
import SyntaxExpression from './syntax_expression'

class SyntaxDocument extends Document
    register_formats: () =>
        # Register Delimiters
        # Add formats
        # Add expressions

    expr: [SyntaxExpression]

    block:
        content: ''
        tag: undefined
        delimiter: undefined

    constructor: (full_document) ->
        super(full_document)
    
    


