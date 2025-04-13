--!strict
--!optimize 2
--!native

-- Signal.luau
-- Signal class for FastNet library.

local Types = require(script.Parent.Types)

return function<T...>() : Types.Signal<T...>

    type Callback = Types.Callback<T...>

    local callbacks : {Callback} = {}
    local threads : {thread} = {}
    local singleCallbacks : {Callback} = {}

    local function connect(callback: Callback) : ()
        table.insert(callbacks, callback)
    end

    local function once(callback: Callback) : ()
        table.insert(singleCallbacks, callback)
    end

    local function wait() : ()
        local thread = coroutine.running()
        table.insert(threads, thread)
        coroutine.yield()
    end

    local function fire(...: T...)
        for _, callback in callbacks do
            coroutine.wrap(callback)(...)
        end

        for _, callback in singleCallbacks do
            coroutine.wrap(callback)(...)
        end

        for _, thread in ipairs(threads) do
            coroutine.resume(thread, ...)
        end
        
        table.clear(threads)
        table.clear(singleCallbacks)
    end

    local function destroy() : ()
        table.clear(callbacks)
        table.clear(threads)
        table.clear(singleCallbacks)
    end

    return table.freeze{
        Connect = connect,
        Once = once,
        Wait = wait,
        Fire = fire,
        Destroy = destroy,
    }
end
