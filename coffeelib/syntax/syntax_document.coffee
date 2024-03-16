
import Document from '../document'
import { strfind, strdiffsimple } from '../str'
import SyntaxExpression from './syntax_expression'
import SyntaxNode from './syntax_node'

class SyntaxDocument extends Document
    register_formats: () =>
        # Register Delimiters
        # Add formats
        # Add expressions

    expr: [SyntaxExpression]

    block:
        content: ''
        tag: undefined
        preambel: undefined
        range: undefined
        range_inner: undefined

        reset: () ->
            this.block.content =  ''
            this.block.tag = undefined
            this.block.range = undefined
            this.block.range_inner = undefined

        next: (lvl = 0) ->
            if this.block.content.length is 0
                pos_current_block = 0
                this.block.content = this.full
            else
                pos_current_block = strfind(this.full, this.block.content)
            pos_next_block = pos_current_block+this.block.content.length+1
            if pos_next_block >= this.full.length
                return next lvl + 1
            
            this.whitespaces.reset()
            this.whitespaces.current_lane = this.full[pos_next_block..strfind(this.full, '\n', pos_next_block)]
            this.whitespaces.update()
            if lvl > this.whitespaces.level
                this.whitespaces.level = this.whitespaces.level + 1
                this.whitespaces.prefixed = this.whitespaces.prefixed + @config.whitespace_prefix

                this.block.content = this.whitespaces.getWholeLevel()
            else if lvl < this.whitespaces.level and lvl >= 0
                this.whitespaces.level = this.whitespaces.level + 1
                this.whitespaces.prefixed = this.whitespaces.prefixed + @config.whitespace_prefix
                
                this.block.content = this.whitespaces.getWholeLevelBefore()
            else
                this.block.content = this.whitespaces.getWholeInnerLevel()
                if this.block.content.length is 0
                    return ''
            pos_end_next_block = strfind(this.full, this.block.content) + this.block.content.length
            this.block.range = new Document.Range pos_next_block, pos_end_next_block + 1, this.block.content
            this.block.detect_preambel()
            return this.block.content

        # Returns [preambel, inner, endtags]
        detect_preambel: () ->
            content = this.block.content
            pos_first_newline = strfind(content, '\n')
            pos_content = strfind(this.full, content)
            this.whitespaces.reset()
            
            this.whitespaces.current_pos = pos_content + pos_first_newline + 1
            this.whitespaces.current_lane = content[..pos_first_newline+1]
            lvl = this.whitespaces.getWholeLevel()
            lvl_inner = this.whitespaces.getWholeInnerLevel()
            diff = strdiffsimple(lvl, lvl_inner) # Returns [before, after, lvl_inner]

            this.block.preambel = diff[0]
            this.block.range = lvl
            this.block.range_inner = lvl_inner
            this.block.tag = new SyntaxNode()
            this.block.tag.body = this.block.range_inner.content
            this.block.tag.preambel = diff[0]
            
        fromRange: (range) ->
            this.block.content = range.content
            this.detect_preambel()

        detect_blocks: (range) ->
            fromRange range
            pos_current_block = strfind(this.full, this.block.content)
            current_lvl = 0
            while pos_next_block = pos_current_block+this.block.content.length+1 < this.full.length
                this.block_ranges.push range
                detect_blocks_inner range, lvl
                next lvl
            return this.block_ranges

        detect_blocks_inner: (range, lvl) ->
            content = this.block.content
            this.whitespaces.current_lane = content[..strfind(range.content, '\n')]
            this.element.reset()

            this.element.full = range.content
            pos_start_block = strfind(this.full, range.content)
            pos_end_block = pos_start_block + range.content.length

            for lvl_idx in [lvl..@config.max_level]
                while pos_end_block < range.content.length
                    pos_start_block = strfind(this.full, range.content)
                    pos_end_block = pos_start_block + range.content.length
                    range_new = new Document.Range pos_start_block, pos_end_block, content
                    this.block_ranges.push range_new
                    if start_inner = this.whitespaces.find_start_inner() isnt -1
                        detect_blocks_inner range_new, lvl_idx+1
                        this.element.full = range.content
                    else break
                    detect_blocks range_new
                    fromRange range_new
                    next lvl
                lvl_idx += 1
            
            this.block.content = content


    block_ranges: [Document.Range]


    constructor: (full_document, { whitespace_prefix = 4, max_level = 7 } = configuration) ->
        super(full_document, configuration)
        this.block.detect_blocks new Range 0, full_document.length, full_document
    
    


