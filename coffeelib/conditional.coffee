

export class Conditional
    _lhs = ''
    _rhs = ''
    _op = ''
    _lhc = null
    _rhc = null

    _parse: (cond) ->
        pos_op = -1
        if strfind(cond, ' is ') > -1
            _op = ' is '
            pos_op = strfind(cond, ' is ')
        else if strfind(cond, ' isnt ') > -1
            _op = ' isnt '
            pos_op = strfind(cond, ' isnt ')
        else if strfind(cond, ' and ') > -1
            _op = ' and '
            pos_op = strfind(cond, ' and ')
        else if strfind(cond, ' or ') > -1
            _op = ' or '
            pos_op = strfind(cond, ' or ')
        else
            for op in [' > ', ' < ', ' >= ', ' =< ']
                if strfind(cond, op) > -1
                    _op = op
                    pos_op = strfind(cond, op)
                    break
        
        if pos_op > -1
            _lhs = cond[..pos_op]
            _rhs = cond[pos_op+op.length+1..]
        else
            _lhs = cond
        
        if op == ' and ' or op == ' or '
            _lhc = new Conditional _lhs
            _rhc = new Conditional _rhs

    constructor: (cond) ->
        this._parse cond
    
    # TODO Write eval with lookup() -> str
    eval: () ->
        if _op == ' and '
            return (_lhc.eval() and _rhc.eval())
        else if _op == ' or '
            return (_lhc.eval() or _rhc.eval())
        else if _op == ' is '
            return (_lhs is _rhs)
        else if _op == ' isnt '
            return (_lhs isnt _rhs)
        else if _op.length == 0
            return true  # TODO This can happen, when we have a lookup field in self._lhs. Returns true for now
        return true
        