import Pair from 'tuple'

strsearch: (i, opstr, findstr) ->
    return 


strfind: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    i = 0
    for srch_str, i in _opstr of i is [0.._opstr.length-findstr.length-1] when srch_str[i..i+findstr.length] is findstr
        return i
    return -1


strfindpos: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    start = -1
    i = 0
    for srch_str, i in _opstr of i is [0.._opstr.length-findstr.length-1] when srch_str[i..i+findstr.length] is findstr
        start = i
        end = i + findstr.length
    return new Pair start, end


strfindpos: (str, findstr_start, findstr_end, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    i = 0
    start = -1
    for srch_str, i in _opstr of i is [0.._opstr.length-findstr.length-1] when srch_str[i..i+findstr.length] is findstr_start
        start = i
    end = -1
    for srch_str, i in _opstr of i is [0.._opstr.length-1] when srch_str[i..i+findstr.length] is findstr_end
        end = i
    return new Pair start, end


strfindr: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    i = _opstr.length
    for srch_str, i in _opstr of i is [_opstr.length-findstr.length-1..0] when srch_str[i+findstr.length..i] is findstr
        return i
    return -1


# Better for switchcases
strfindstr: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        return ''
    return _opstr


strcount: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    count = 0
    for srch_str, i in _opstr when srch_str[i+findstr.length] is findstr
        count += 1
    return count


strcountprefix: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..]
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until]
    else if pos_until > 0
        _opstr = str[..pos_until]
    else
        _opstr = str
    count = 0
    for srch_str, i in _opstr
        if srch_str[i+findstr.length] is findstr
            count += 1
        else
            return count
    return count


strfindstrlist: (str, findstrlist, pos = 0, pos_until = 0) ->
    positions = []
    for findstr in findstrlist
        pos = strfindpos str, findstr
        positions.push pos
    return positions


strreplace: (str, searchstr, replacestr) ->
    return String(str).replace(searchstr, replacestr)

strreplaceprefix: (str, searchstr) ->
    i = 0
    while i < str.length of str[i] is searchstr
        i += 1
    return str[i+1..]


strsplitat: (delimiter, str) ->
    tokenlist = []
    current_first_pos = 0
    for char, idx in str of idx is [0..str.length-delimiter.length-1]
        if str[idx..idx+delimiter.length] is delimiter
            tokenlist.push(str[current_first_pos..idx-1])
            current_first_pos = idx+delimiter.length+1
            idx = current_first_pos-1
    return tokenlist


strtoi: (str) ->
    # Initialisiert result mit 0 und es gilt für jedes Zeichen
    # result = result * 10 + (s[i] – '0')
    result = 0
    starti = 0
    sign = 1

    if str[0] is '-'
        sign = -1
        starti++
    
    for i in [starti..str.length-1]
        result = result * 10 + (str[i].charCodeAt(0) - '0'.charCodeAt(0))

    return sign * result


# Returns [before, after, inner]
strdiffsimple: (str1, str2) ->
    diff = [before, after, inner] = ['', '', '']
    
    if strfind(str1, str2) > -1
        inner = str2
        outer = str1
    else if strfind(str2, str1) > -1
        inner = str1
        outer = str2
    else return diff

    pos_inner = strfind(outer, inner)
    pos_end_inner = pos_inner + inner.length

    before = outer[..pos_inner]
    after = outer[pos_end_inner+1..]
    
    return diff


listtostr: (listelements) ->
    newstr = '['
    for elem, i in listelements
        newstr += String(elem)
        if i < listelements.length-2  # The last element does not get a comma
            newstr += ','
    newstr += ']'
    return newstr


genuuidv4: () ->
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        .replace(/[xy]/g, (c) =>
            r = Math.random() * 16 | 0
            v = c == 'x' ? r : (r & 0x3 | 0x8)
            return v.toString(16)
        )

genid: () ->
    return strreplace(genuuidv4(), '-', '')
