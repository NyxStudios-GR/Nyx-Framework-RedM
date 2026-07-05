function Nyx.TriggerServerCallback(name, cb, ...)
    assert(type(name) == 'string' and name ~= '', 'callback name must be string')
    assert(type(cb) == 'function', 'callback handler must be function')

    Nyx.CurrentRequestId = Nyx.CurrentRequestId + 1
    local requestId = Nyx.CurrentRequestId

    Nyx.ServerCallbacks[requestId] = cb
    TriggerServerEvent('nyx:triggerServerCallback', name, requestId, ...)

    SetTimeout(Config.CallbackTimeoutMs, function()
        if Nyx.ServerCallbacks[requestId] then
            Nyx.ServerCallbacks[requestId] = nil
            cb(nil, 'timeout')
        end
    end)
end

RegisterNetEvent('nyx:serverCallback', function(requestId, ...)
    local cb = Nyx.ServerCallbacks[requestId]
    if not cb then return end

    Nyx.ServerCallbacks[requestId] = nil
    cb(...)
end)

function Nyx.RegisterClientCallback(name, cb)
    assert(type(name) == 'string' and name ~= '', 'callback name must be string')
    assert(type(cb) == 'function', 'callback handler must be function')
    Nyx.ClientCallbacks[name] = cb
end

RegisterNetEvent('nyx:triggerClientCallback', function(name, requestId, ...)
    local cb = Nyx.ClientCallbacks[name]
    if not cb then
        TriggerServerEvent('nyx:clientCallback', requestId, nil, 'missing_callback')
        return
    end

    local responded = false
    cb(function(...)
        if responded then return end
        responded = true
        TriggerServerEvent('nyx:clientCallback', requestId, ...)
    end, ...)
end)

exports('TriggerServerCallback', function(name, cb, ...)
    return Nyx.TriggerServerCallback(name, cb, ...)
end)

exports('RegisterClientCallback', function(name, cb)
    return Nyx.RegisterClientCallback(name, cb)
end)
