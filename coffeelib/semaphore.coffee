
import { Event as BaseEvent, EventQueueHandler as BaseEventQueueHandler } from './event'
import { EventHandler as BaseEventHandler } from './event'
import { MultiqueueNamed as BaseMultiqueueNamed, Queue } from './queue'
import { strfind, strsplitat, strtoi } from './str'


class Semaphore
    Options = {
        locktype: ''
        lockobject: ''
    }

    # Please at least implement BaseEvent.Reflector for all classes using the Semaphore
    class Event extends BaseEvent
        options = Semaphore.Reasoner.Options
        class Reflector extends BaseEvent.Reflector
            startEvent: () => return 'event_started'
            startEvent: (semaphore) => return 'event_started_with_semaphore'
            answerEvent: () => return 'event_answered'
            awaitFor: () => return 'await_now'
            awaitFor: (semaphore) =>
                return semaphore.awaitFor '' + await_locktype + ' ' + await_version, this

            await_locktype: '#'
            await_version: -1
            lockobject_type: 'semaphore'
            caller: undefined
            await_status: 'new'


        constructor: (@using_class, opts = Semaphore.EventQueue.Options) ->
            super({ eventType: 'SemaphoreReasonerEvent' })

        eventFunctionality: () ->
            startEvent()
            yield @using_class.answerEvent()
        
        startEvent: () ->
            return @using_class.startEvent()
        
        startEvent: (semaphore) =>
            return @using_class.startEvent semaphore

    # In the Reasoner all processes can await that a semaphore is free
    class Reasoner extends EventHandler
        Options = {
            awaitfor_locktype: ''
            awaitfor_version: ''
            lockobject_type: ''
            caller: undefined
        }

        
        inform_on_version_change: () ->
            current_version = @semaphore.await_version
            await @semaphore.await_version isnt current_version
            return [current_version, @semaphore.await_version]

        inform_on_version_is: (opts) ->
            await @semaphore.await_version is opts.awaitfor_version
            return true
        
        inform_on_locktype_change: () ->
            current_locktype = @semaphore.await_locktype
            await @semaphore.await_locktype isnt current_locktype
            return [current_locktype, @semaphore.await_locktype]
        
        inform_on_locktype_is: (opts) ->
            await @semaphore.await_locktype is opts.awaitfor_locktype
            return true


        constructor(@semaphore, @eventQueueHandler) ->
            @queue = new Queue()
            @eventQueueHandler.install_queue @queue
        

        awaitnext: () ->
            await this.inform_on_locktype_change @semaphore or this.inform_on_version_change @semaphore
            return true

        awaitsfor: (event) ->
            while awaitnext @semaphore
                if event.options.awaitfor_locktype is @semaphore.await_locktype
                    return true
                else if event.options.awaitfor_version is @semaphore.await_version
                    return true
                else if event.options.awaitfor_locktype is '#'
                    return true
                else if event.options.awaitfor_version is -1
                    return true
                else
                    continue
            return false

        awaitthere: (opt) ->
            event = new Semaphore.Event opt.caller, opt
            
            @eventQueueHandler.pre_push event, 'awaithere'
            @queue.push event
            
            # Before returning the event, it'll update the opts
            @eventQueueHandler.after_push event, 'awaitthere', this
            yield return event

        startNext: (opt) ->
            if opt.awaitfor_locktype is @semaphore.await_locktype or opt.awaitfor_version is @semaphore.await_version
                event = new Semaphore.Event opt.caller, opt
                return @semaphore.startEvent event
            
            # TODO If fitting level, process this first
            # TODO If fitting locktype, process this now

            event = @eventQueueHandler.pop @semaphore
            return [opt, event]

        startNow: () ->
            opt = Semaphore.Reasoner.Options += {
                awaitfor_locktype: 'reasoner'
                awaitfor_version: '-1'
                lockobject_type: 'semaphore.reasoner'
                caller: this
            }

            [opt, event] = await startNext opt
            
            # On success, we update the semaphore's properties
            if event?
                @semaphore.await_locktype = opt.awaitfor_locktype
                @semaphore.await_version = opt.awaitfor_version
            return opt



    isfile: false
    options: Semaphore.Options
    version: 0
    
    class EventQueueHandler extends BaseEventQueueHandler
        constructor: (@semaphore) ->
            props = {
                process_incoming: false
            }
            super(props)
            @queue = new BaseMultiqueueNamed()
        
        # A Reasoner awaits until after push returns
        pre_push: (event, param) ->
            if param is 'awaitthere'
                event.using_class.await_status = 'waiting'

        after_push: (event, param, reasoner) ->
            if param isnt 'awaitthere'
                return
            
            # Register handlers

        pre_pop: (semaphore) ->
            event = @queue[0]
            if event.options.awaitfor_locktype isnt semaphore.await_locktype and event.options.awaitfor_version isnt semaphore.await_version
                throw new Error "NotNow to startfrom queue"
        
        after_pop: (event, semaphore) ->
            return await event.startEvent semaphore

        pop: (semaphore) ->
            try
                this.pre_pop semaphore
                event = @queue.pop()
                this.after_pop event, semaphore
            catch Error
                return undefined
            return event


        after_processing: (event, params) ->
            params = strsplitat ' ', params
            locktype_changed = ''
            if 'dont_continue' in params
                yield return
                return
            else if 'locktype_changed' in params
                for param, idx in params of idx is [0..params.length-2] when param is 'locktype_changed'
                    locktype_changed = params[idx+1]
            
            if 'semaphore_free' in params
                yield 'next' + if locktype_changed.length > 0 then ' ' + locktype_changed
                @semaphore.tryStartNow()

            return true
        

    @eventQueueHandler = undefined
    @reasoner: undefined

    constructor: (locktype, lockobject, is_file = false) ->
        opt = Semaphore.Options
        opt.locktype = locktype
        opt.lockobject = lockobject
        isfile = isfile
        leaseduration = lease_duration
        @eventQueueHandler = new EventQueueHandler this
        @reasoner = new Reasoner @eventQueueHandler
    
    # Returns 'new_locktype new_level' on success, status parameters else
    tryStartNow: () ->
        return @reasoner.startNow()

    # Additionaly use exceptionally events
    awaitFor: (params = '', waiter = undefined) ->
        param = strsplitat ' ', params
        # Await for semaphore yourself's reasoner queue whilst event handling
        if params.length is 0

            yield await @reasoner.awaitthere()
            
            return tryStartNow()
        # If some one likes to wait for the semaphore, it'll land here
        # If there is exactly two parameters, it is semaphore_lock_type
        # (own type of waiting functionality) and semaphore level
        # Can also be '# -1' for just await next
        else if waiter isnt undefined
            locktype = param[0]
            level = strtoi(param[1])

            waiter_options = Semaphore.Event.Options += {
                awaitfor_locktype: waiter.await_locktype
                awaitfor_version: waiter.await_version
                caller: waiter
            }
            
            event = await @reasoner.awaitthere waiter_options
            if locktype is '#' and level is -1 # Just wait for next free shedule place

            else if locktype is '#' # Wait for a semaphore level

            else if level is -1 # Wait for whatever semaphore level that returns

            else # Wait for exactly my constraints
                return
        else # This happens when someone waits with only a parameter list or only one parameter
            return


        # Inform the others that the params for awaiting changed


    # The Reasoning.Reflector is 
    answerEvent: () ->
    startEvent: (event) ->
        return await event.startEvent this

    
    


