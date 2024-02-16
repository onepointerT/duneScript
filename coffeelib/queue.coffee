
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


class Multiqueue extends Queue
    constructor: (@queueCount) ->
        super()
        @queues = [Queue]
        for i in [0..@queueCount]
            @queues.push new Queue()
        # TODO: Check size
    
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
    
    pop: () ->
        [lq, lql] = this.longestQueue()
        return @queue[lq].pop()



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
        while queue.length < @queueStrength+1
            elem = super.pop()
            @queue.push elem
        return @queue.pop()
    
    pop: () ->
        return this.next()

