// @flow

strfind: (str ###: string ###, findstr ###: string ###, pos = 0 ###: Integer ###, pos_until = 0 ###: Integer ###) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    for srch_str, i in _opstr when srch_str is findstr
        return i
    return 0

strfindr: (str ###: string ###, findstr ###: string ###, pos = 0 ###: Integer ###, pos_until = 0 ###: Integer ###) ->
    if pos > 0
        _opstr = str[pos..].reverse()
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until].reverse()
    else if pos_until > 0
        _opstr = str[..pos_until].reverse()
    else
        _opstr = str
    for srch_str, i in _opstr[_opstr.length..0] when srch_str is findstr
        return i
    return 0


_parse_until_line_end: (datastr ###: string ###) ->
    return datastr[0..strfind(datastr, '\n')]

_parse_sequence: (datastr ###: string ###, start ###: Integer ###) ->
    lane_start = datastr[start]
    i = strfind(datastr, '- ', start)
    elements = []
    while lane_start is '-'
        newline = strfind(datastr, '\n', i)
        lane = datastr[i..newline]
        if lane is not undefined and lane.length > 0
            elements.push(lane)
        i = strfind(datastr, '- ', newline)
        if i is 0
            return elements
        lane_start = datastr[i]
    return elements


_parse_mapping: (datastr ###: string ###, start ###: Integer ###) ->
    ls = start
    d = strfind(datastr, ': ', start)
    elements = {}
    while d isnt undefined
      # TODO: Without newline
        newline = strfind(datastr, '\n', d)
        lane = datastr[d+2..newline]
        key = datastr[ls..d-1]
        if lane isnt undefined and lane.length > 0
            elements[key] = lane
        d = strfind(datastr, ': ', newline)
        if d is 0
            return elements
    return elements


_parse_mapping_sequence: (datastr ###: string ###, start ###: Integer ###) ->
    elements = {}
    ls = start
    while d = strfind(datastr, ': ', ls) isnt undefined
        key = datastr[ls..d]
        elements[key] = _parse_sequence(datastr, strfind(datastr, '\n', d+1))
    return elements


_parse_sequence_of_mappings: (datastr ###: string ###, start ###: Integer ###) ->
    elements = []
    ls = start
    while d = strfind(datastr, '- ', ls) isnt undefined
        elem = _parse_mapping(datastr, d+2)
        elements.push elem
    return elements


_parse_sequence_of_sequences: (datastr ###: string ###, start ###: Integer ###) ->
    elements = []
    ls = start
    while d = strfind(datastr, '- [', ls) isnt undefined
        elem = []
        cpos = d
        while k = strfind(datastr, ', ', cpos) isnt undefined
            elem.push datastr[cpos..k-1]
            cpos = k+2
        elem.push datastr[cpos..strfind(datastr, ']', cpos)-1]
        elements.push elem
    return elements


_parse_mapping_of_mappings: (datastr ###: string ###, start ###: Integer ###) ->
    elements = {}
    ls = start
    while d = strfind(datastr, ': ', ls) isnt undefined
        elem = _parse_mapping(datastr, strfind(datastr, '{'))
        key = datastr[ls..d-1]
        elements[key] = elem
    return elements


_


YamlTypes =
    Sequence: "sequence"
    Mapping: "mapping"
    MappingSequence: "mapping_sequence"
    MappingOfSequences: "mapping_of_sequences"
    MappingOfMappings: "mapping_of_mappings"
    SequenceOfSequences: "sequence_of_sequences"
    SequenceOfMappings: "sequence_of_mappings"
    Multiline: "multiline"
    GenericYaml: "generic_yaml"


    whats_this: (datastr ###: string ###, start ###: Integer ###, end = start ###: Integer ###) ->
        # TODO:
        if end isnt start

        return YamlTypes.GenericYaml


_parse_elem: (datastr ###: string ###, start ###: Integer ###) ->
