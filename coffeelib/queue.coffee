
class Queue extends []
    sort: () ->
    
    next: () ->
        return super.pop()

    constructor: () ->
        super()
        this.sort()

    pop: () ->
        return this.next()

    push: (item) ->
        super.push(item)
    
    hasElem: () ->
        return (this.length > 0)
    
    pushMulti: (items) ->
        for item in items
            this.push item


class Multiqueue extends Queue
    constructor: (@queueCount, queue_base_class = Queue) ->
        super()
        @queues = [Queue]
        for i in [0..@queueCount]
            this.new_queue queue_base_class
        # TODO: Check size
    
    new_queue: (queue_base_class) ->
        @queues.push new (typeof queue_base_class)()

    next: () ->
        for i in [0..@queueCount]
            if @queues[i].length > 0
                return @queues[i].pop()
        return null

    shortestQueue: () ->
        shortest_queue = -1
        shortest_queue_length = 0
        for i in [0..@queueCount]
            if @queues[i].length == 0
                continue
            else if @queues[i].length > 0
                if shortest_queue is -1
                    shortest_queue = i
                    shortest_queue_length = @queues[i].length
                else if @queues[i].length < shortest_queue_length
                    shortest_queue = i
                    shortest_queue_length = @queues[i].length
        return [shortest_queue, shortest_queue_length]
    
    longestQueue: () ->
        longest_queue = -1
        longest_queue_length = 0
        for i in [0..@queueCount]
            if @queues[i].length > 0
                if longest_queue == -1
                    longest_queue = i
                    longest_queue_length = @queues[i].length
                else if @queues[i].length > longest_queue_length
                    longest_queue = i
                    longest_queue_length = @queues[i].length
        return [longest_queue, longest_queue_length]

    
    push: (item) ->
        [sq, sql] = this.shortestQueue()
        @queue[sq].push item
    
    pushIn: (queue_num, item) ->
        if queue_num < @queue.length
            @queue[queue_num].push item
    
    pop: () ->
        [lq, lql] = this.longestQueue()
        return @queue[lq].pop()
    
    popOf: (queue_num) ->
        if queue_num > @queue.length - 1
            return null
        return @queue_num[queue_num].pop()



class MultiqueueNamed extends Multiqueue
    class QueuePairNamed
        name: ''
        queue: undefined

        constructor: (queue_name, new_queue = undefined) ->
            @name = queue_name
            if queue is undefined
                @queue = new Queue
            else
                @queue = new Queue

        length: () -> return @queue.length
        push: (elem) -> @queue.push elem
        pop: () -> return @queue.pop()
        popFrom: (i) ->
            elem = @queue[i]
            delete @queue[i]
            return elem
    
    constructor: (queue_base_class) ->
        super(0)

    findByName: (queue_name) ->
        for queue_pair in @queue
            if queue_pair.name is queue_name
                return queue_pair
        return undefined
    
    popOf: (queue_name) ->
        queue = this.findByName queue_name
        if queue?
            return queue.pop()
        return undefined

    pushIn: (queue_name, item) ->
        queue = this.findByName queue_name
        if queue?
            queue.push item



# Birch First Solver
# Works like in this ASCII art:
#
#   ---\ 
# ------> -----
#  ----/
class BFS extends Multiqueue 
    @queue = []

    constructor: (laneCount = 2, @queueStrength = 4) ->
        super(laneCount)
        @queue = new Queue()

    next: () ->
        while @queue.length < @queueStrength+1
            elem = super.pop()
            @queue.push elem
        return @queue.pop()
    
    pop: () ->
        return this.next()
    
    hasElem: () ->
        return (@queue.length > 0)

