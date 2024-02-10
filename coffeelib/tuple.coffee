# @flow

class Pair
    constructor: (@first, @second) ->


class Tuple extends Pair
    constructor: (e1, e2, @map = {}) ->
        super e1, e2
