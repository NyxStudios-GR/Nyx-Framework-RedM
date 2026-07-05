local function canUseCallback(src, name)
    if src == 0 then return true end

    local now = GetGameTimer()
    Nyx.CallbackCooldowns[src] = Nyx.CallbackCooldowns[src] or {}
    local last = Nyx.CallbackCooldowns[src][name] or 0

    if now - last < Config.CallbackCooldownMs then
        return false
    end

    Nyx.CallbackCooldowns[src][name] = now
    return true
end

function Nyx.RegisterServerCallback(name, cb)
    assert(type(name) == 'string' and name ~= '', 'callback name must be string')
    assert(type(cb) == 'function', 'callback handler must be function')
    Nyx.ServerCallbacks[name] = cb
end

RegisterNetEvent('nyx:triggerServerCallback', function(name, requestId, ...)
    local src = source
    name = tostring(name or '')

    if not canUseCallback(src, name) then
        TriggerClientEvent('nyx:serverCallback', src, requestId, nil, 'rate_limited')
        return
    end

    local cb = Nyx.ServerCallbacks[name]
    if not cb then
        print(('^1[Nyx_Core]^7 Missing server callback: %s'):format(name))
        TriggerClientEvent('nyx:serverCallback', src, requestId, nil, 'missing_callback')
        return
    end

    local responded = false
    local function respond(...)
        if responded then return end
        responded = true
        TriggerClientEvent('nyx:serverCallback', src, requestId, ...)
    end

    local ok, err = pcall(cb, src, respond, ...)
    if not ok then
        print(('^1[Nyx_Core]^7 Callback error [%s]: %s'):format(name, err))
        respond(nil, 'callback_error')
    end
end)

function Nyx.TriggerClientCallback(source, name, cb, ...)
    source = tonumber(source)
    assert(source and source > 0, 'source must be a player id')
    assert(type(name) == 'string' and name ~= '', 'callback name must be string')
    assert(type(cb) == 'function', 'callback handler must be function')

    Nyx.ClientCallbackId = Nyx.ClientCallbackId + 1
    local requestId = Nyx.ClientCallbackId

    Nyx.ClientCallbacks[requestId] = cb
    TriggerClientEvent('nyx:triggerClientCallback', source, name, requestId, ...)

    SetTimeout(Config.CallbackTimeoutMs, function()
        if Nyx.ClientCallbacks[requestId] then
            Nyx.ClientCallbacks[requestId] = nil
            cb(nil, 'timeout')
        end
    end)
end

RegisterNetEvent('nyx:clientCallback', function(requestId, ...)
    local cb = Nyx.ClientCallbacks[requestId]
    if not cb then return end

    Nyx.ClientCallbacks[requestId] = nil
    cb(...)
end)

Nyx.RegisterServerCallback('nyx:getPlayerData', function(source, cb)
    local player = Nyx.GetPlayerFromId(source)
    cb(player and player:toClient() or nil)
end)

exports('RegisterServerCallback', function(name, cb)
    return Nyx.RegisterServerCallback(name, cb)
end)

exports('TriggerClientCallback', function(source, name, cb, ...)
    return Nyx.TriggerClientCallback(source, name, cb, ...)
end)
