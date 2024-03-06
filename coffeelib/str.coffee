import Pair from 'tuple'

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
    for srch_str, i in _opstr[i..findstr.length] of i is [0.._opstr.length-findstr.length] when srch_str is findstr
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
    for srch_str, i in _opstr[i..findstr.length] of i is [0.._opstr.length-findstr.length] when srch_str is findstr
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
    start = -1
    for srch_str, i in _opstr[i..findstr_start.length] of i is [0.._opstr.length-findstr.length] when srch_str is findstr_start
        start = i
    end = -1
    for srch_str, i in _opstr[i..findstr_end.length] of i is [0.._opstr.length] when srch_str is findstr_end
        end = i
    return new Pair start, end


strfindr: (str, findstr, pos = 0, pos_until = 0) ->
    if pos > 0
        _opstr = str[pos..].reverse()
    else if pos_until > 0 and pos > 0
        _opstr = str[pos..pos_until].reverse()
    else if pos_until > 0
        _opstr = str[..pos_until].reverse()
    else
        _opstr = str
    for srch_str, i in _opstr[i..findstr.length] of i is [0.._opstr.length-findstr.length] when srch_str is findstr
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


strfindstrlist: (str, findstrlist, pos = 0, pos_until = 0) ->
    positions = []
    for findstr in findstrlist
        pos = strfindpos str, findstr
        positions.push pos
    return positions


strreplace: (str, searchstr, replacestr) ->
    return String(str).replace(searchstr, replacestr)

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
