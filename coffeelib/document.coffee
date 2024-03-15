
import { strcount, strcountprefix, strfind, strfindpos, strfindr } from './str'

class Document extends {}
    full: ''
    previous: ''
    current: ''
    next: ''
    formats: [Document.Format]

    register_formats: () =>

    constructor: (full_document, { whitespace_prefix = 4 } = configuration) ->
        super()
        full = full_document
        @config = configuration
        register_formats()


    whitespaces:
        level: 0
        prefixed: 0
        current_lane: ''
        current_pos: -1

        reset: () ->
            this.whitespaces.level = 0
            this.whitespaces.prefixed = 0
            this.whitespaces.current_lane = ''
            this.whitespaces.current_pos = -1

        next_newline: (element, idx) ->
            pos_current_newline = strfind(element, '\n', idx)
            return element[pos_current_newline+1..]
        
        next_newline: () ->
            if this.whitespaces.current_lane.length > 0
                pos_current_lane = strfind(this.full, this.whitespaces.current_lane,
                                            if this.whitespaces.current_pos < 0 then 0 else this.whitespaces.current_pos)
            else
                pos_current_lane = 0
                this.whitespaces.current_lane = this.full[..strfind(this.full, '\n')]
                this.whitespaces.current_pos = 0
            pos_current_newline = strfindr(this.whitespaces.current_lane, '\n')
            pos_next_newline = strfind(this.full, '\n', pos_current_lane+pos_current_newline+1)
            new_element = this.full[pos_current_lane+pos_current_newline+1..pos_next_newline+1]
            this.element.reset()
            this.element.current = new_element
            this.element.delimiter_end = '\n'
            this.whitespaces.current_pos = pos_current_lane+pos_current_newline+1
            this.whitespaces.current_lane = new_element
            this.whitespaces.update()
            return new_element
    
        strip_current_level: (element) ->
            count_linebreaks = strcount(element, '\n')

            i = 0
            new_elem = ''
            while i < count_linebreaks
                current_lane = next_newline i
                new_elem += strreplaceprefix(next_newline, ' ')
                i += 1
            return new_elem
        
        strip_white_spaces: () ->
            if this.whitespaces.current_lane.length > 0
                cl = this.whitespaces.current_lane
                while cl[0..1]? is ' '
                    cl = if cl.length == 0 then '' else cl[1..]
            else return ''
            return cl

        update: () ->
            if this.whitespaces.current_lane.length > 0
                wsc = 0
                while this.whitespaces.current_lane[0..1]? is ' '
                    wsc += 1
                this.whitespaces.level = wsc / this.config.whitespace_prefix
                this.whitespaces.prefixed = wsc
            else
                this.whitespaces.level = 0
                this.whitespaces.prefixed = 0


        getWholeLevel: () ->
            this.whitespaces.update()
            pos_current_lane = strfind(this.full, this.whitespaces.current_lane,
                                        if this.whitespaces.current_pos < 0 then 0 else this.whitespaces.current_pos)
            pos_current_newline = strfindr(this.whitespaces.current_lane, '\n')
            cl = this.whitespaces.current_lane
            new_element = ''
            while cl? and strcountprefix(cl, ' ') >= this.whitespaces.prefixed
                new_element += cl
                pos_current_lane = pos_current_lane + pos_current_newline + 1
                cl = this.full[pos_current_lane..strfind(this.full, '\n', pos_current_lane)]
                pos_current_newline = pos_current_lane + strfind(cl, '\n')
            this.element.reset()
            this.element.full = new_element
            this.element.delimiter_end = '\n'
            return new_element
        
        getWholeLevelBefore: () ->
            this.whitespaces.update()
            pos_current_lane = strfind(this.full, this.whitespaces.current_lane,
                                        if this.whitespaces.current_pos < 0 then 0 else this.whitespaces.current_pos)
            pos_current_newline = strfindr(this.whitespaces.current_lane, '\n')
            cl = this.whitespaces.current_lane
            new_element = ''
            while cl? and strcountprefix(cl, ' ') >= this.whitespaces.prefixed
                pos_current_lane = pos_current_lane - 1
                cl = this.full[strfindr(this.full, '\n', pos_current_lane-2)+1..pos_current_lane-1]
            this.whitespaces.current_lane = cl
            return this.getWholeLevel()



    element:
        full: ''
        key: ''
        content: ''
        delimiter_end: ''

        reset: () ->
            this.element.full = ''
            this.element.key = ''
            this.element.content = ''
            this.element.delimiter_end = ''

        update: () ->
            pos_content_start = strfind(this.element.full, @keyDelimiter)
            if @keyDelimiter.length is 0
                this.element.key = ''
            this.element.content = this.element.full[pos_content_start..]
            if @delimiterElementEnd.length > 0
                pos_delimiter_end = strfindr(this.element.full, @delimiterElementEnd, this.element.full.length-@delimiterElementEnd.length*4)
                this.element.delimiter_end = this.element.content[pos_delimiter_end..]
                this.element.content = this.element.content[..pos_delimiter_end]
        
        previous: () ->
            pos_start_element = strfind(this.full, this.element.full)
            if pos_start_element <= 0
                return
            this.whitespaces.current_lane = this.full[strfindr(this.full, '\n', 0, pos_start_element-2)+1..pos_start_element-1]
            this.whitespaces.getWholeLevelBefore()
            this.element.update()
            return this.element.full

        next: () ->
            pos_end_element = strfind(this.full, this.element.full) + this.element.full.length
            pos_start_element = pos_end_element + 1
            pos_first_newline = strfind(this.full, '\n', pos_start_element)
            this.whitespaces.current_lane = this.full[pos_start_element..pos_first_newline]
            this.whitespaces.getWholeLevel()
            this.element.update()
            return this.element.full
    
    update_current: () ->
        this.element.full = this.current
        this.element.update()

    previous_element: () ->
        pos = find_previous
        this.next = this.current
        this.current = this.previous
        this.previous = this.full[pos.start..pos.end]
        update_current

    next_element: () ->
        this.
        pos = find_next
        this.previous = this.current
        this.current = this.next
        this.next = this.full[pos.start..pos.end]
        update_current
    
    class Format
        DataTypes:
            Generic: 'generic'
            Multiline: 'multiline'
        
        class Delimiter extends Pair
            contructor: (@name, start, end) ->
                super(start, end)

            start: -> return @first
            end: -> return @second
            stringify: ->
                return """{
                    name: "#{this.name}"
                    start: "#{this.start}"
                    end: "#{this.end}"
                    }
                """

            typeis: () =>
                switch @name
                    when DataTypes.Multiline then return DataTypes.Multiline
                    when DataTypes.Generic then return DataTypes.Generic
        
        @delimiters = {}
        find_delimiter: (delimitername) ->
            for delim_name, delims in @delimiters
                if delim_name is delimitername
                    return delim
            return []

        register_delimiter: (delimitername, start, end) ->
            delim = new Delimiter delimitername, start, end
            if this.find_delimiter(delimitername).length is 0
                @delimiters[delimitername] = [Delimiter]
            @delimiters[delimitername].push delim
        
        forall_delimiters: (delimitername, func, args...) ->
            delims = this.find_delimiter delimitername
            for delim_name, delim_list in delims
                if delim_name is delimitername
                    for delim in delim_list
                        func(delim, args)
        
        forall_delimiters: (func, args...) ->
            for delims in @delimiters
                for delim in delims
                    func(delim, args)

        # Finds out which of all types is delimited here
        # TODO Mode strict=false, where the start end the end delimiter is searched for
        which: (str) ->
            return forall_delimiters( (delimiter, args...) =>
                correct_start = true
                correct_end = true
                if delimiter.start?
                    if delimiter.start isnt str[..delimiter.length]
                        correct_start = false
                if delimiter.end?
                    if delimiter.end isnt str[..str.length-delimiter.length]
                        correct_end = false
                if correct_start and correct_end
                    return delimiter
                ; str
            )

        whats_this_if_generic: (delim, element) =>
        whats_this_if_multiline: (delim, element) =>

        # Find out what this element is (what is in there)
        whats_this: (element) ->
            inthere_list = []
            which_this = which element
            switch which_this
                when DataTypes.Mapping
                    mapping = find_delimiter DataTypes.Mapping
                    inner_str = element[mapping.start.length..element.length-mapping.start.length-mapping.end.length]
                    inner_is = which inner_str
                    switch inner_is.typeis
                        when DataTypes.Sequence
                            return DataTypes.MappingOfSequences
                        when DataTypes.Mapping
                            return DataTypes.MappingOfMappings
                    
                    return DataTypes.Mapping
                when DataTypes.Sequence
                    sequence = find_delimiter DataTypes.Sequence
                    inner_str = element[mapping.start.length..element.length-mapping.start.length-mapping.end.length]
                    inner_is = which inner_str
                    switch inner_is.typeis
                        when DataTypes.Mapping
                            return DataTypes.SequenceOfMappings
                        when DataTypes.Sequence
                            return DataTypes.SequenceOfSequences
                    
                    return DataTypes.Sequence
                when DataTypes.Multiline
                    multiline = find_delimiter DataTypes.Multiline
                    return whats_this_if_multiline which_this, element[multiline.start.length..-multiline.end.length]
                when DataTypes.Generic
                    return whats_this_if_generic which_this, element
            return which_this

        inner: (element) ->
            wte = whats_this element
            return element[wte.start.length..element.length-wte.start.length-wte.end.length]

        constructor: (@keyDelimiter = ': ', @data_type = DataTypes, @delimiterElementEnd = '') ->
