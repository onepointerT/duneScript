strfind: (str, findstr, pos = 0, pos_until = 0) ->
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

strfindr: (str, findstr, pos = 0, pos_until = 0) ->
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
