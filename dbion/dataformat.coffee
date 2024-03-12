
import { strcount, strcountprefix, strfind, strfindpos, strfindr } from '../coffeelib/str'
import Pair from '../coffeelib/tuple'


DataTypes =
    Sequence: "sequence"
    Mapping: "mapping"
    MappingSequence: "mapping_sequence"
    MappingOfSequences: "mapping_of_sequences"
    MappingOfMappings: "mapping_of_mappings"
    SequenceOfSequences: "sequence_of_sequences"
    SequenceOfMappings: "sequence_of_mappings"
    Multiline: "multiline"
    SingleElement: "single_element"
    Generic: "generic"

        
        
class DataFormat
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
                when DataTypes.Sequence then return DataTypes.Sequence
                when DataTypes.Mapping then return DataTypes.Mapping
                when DataTypes.MappingSequence then return DataTypes.MappingSequence
                when DataTypes.MappingOfSequences then return DataTypes.MappingOfMappings
                when DataTypes.MappingOfMappings then return DataTypes.MappingOfMappings
                when DataTypes.SequenceOfSequences then return DataTypes.SequenceOfSequences
                when DataTypes.SequenceOfMappings then return DataTypes.SequenceOfMappings
                when DataTypes.Multiline then return DataTypes.Multiline
                when DataTypes.Generic then return DataTypes.Generic
                #default then return DataTypes.Generic
     
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


    # TODO Implement only closing tag for finds of document property
    document =
        full: ''
        previous: ''
        current: ''
        next: ''

        find_element: () -> return strfindpos(document.full, document.current)
        find_previous: () -> return strfindpos(document.full, document.previous)
        find_next: () -> return strfindpos(document.full, document.next)

        whitespaces:
            level: 0
            prefixed: 0

            strip_current_level: (element) ->
                count_linebreaks = strcount(element, '\n')

                next_newline = (idx) ->
                    pos_current_newline = strfind(element, '\n', idx)
                    return element[pos_current_newline+1..]

                i = 0
                new_elem = ''
                while i < count_linebreaks
                    current_lane = next_newline i
                    new_elem += strreplaceprefix(next_newline, ' ')
                    i += 1
                return new_elem


        element:
            full: ''
            key: ''
            content: ''
            delimiter_end: ''

            update: () ->
                pos_content_start = strfind(document.element.full, @keyDelimiter)
                if @keyDelimiter.length is 0
                    document.element.key = ''
                document.element.content = document.element.full[pos_content_start..]
                if @delimiterElementEnd.length > 0
                    pos_delimiter_end = strfindr(document.element.full, @delimiterElementEnd, document.element.full.length-@delimiterElementEnd.length*4)
                    document.element.delimiter_end = document.element.content[pos_delimiter_end..]
                    document.element.content = document.element.content[..pos_delimiter_end]
        
        update_current: () ->
            document.element.full = document.current
            document.element.update()

        previous_element: () ->
            pos = find_previous
            document.next = document.current
            document.current = document.previous
            document.previous = document.full[pos.start..pos.end]
            update_current

        next_element: () ->
            pos = find_next
            document.previous = document.current
            document.current = document.next
            document.next = document.full[pos.start..pos.end]
            update_current


    constructor: (@keyDelimiter = ': ', @data_type = DataTypes, @delimiterElementEnd = '') ->
