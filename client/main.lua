Nyx = Nyx or {}
Nyx.PlayerData = {}
Nyx.ClientCallbacks = {}
Nyx.ServerCallbacks = {}
Nyx.CurrentRequestId = 0
Nyx.Ready = false

function Nyx.GetCoreObject()
    return Nyx
end

function Nyx.GetPlayerData()
    return Nyx.PlayerData
end

function Nyx.IsPlayerLoaded()
    return Nyx.Ready
end

function Nyx.Notify(message, notifyType, duration, title)
    local payload = type(message) == 'table' and message or {
        message = tostring(message or ''),
        type = notifyType or Config.Notify.DefaultType,
        duration = duration or Config.Notify.DefaultDuration,
        title = title or 'Nyx'
    }

    payload.message = tostring(payload.message or '')
    payload.type = payload.type or Config.Notify.DefaultType
    payload.duration = tonumber(payload.duration) or Config.Notify.DefaultDuration
    payload.title = payload.title or 'Nyx'

    if Config.Notify.UseNui then
        SendNUIMessage({ action = 'notify', data = payload })
        return
    end

    TriggerEvent('chat:addMessage', {
        color = { 180, 70, 255 },
        multiline = true,
        args = { payload.title, payload.message }
    })
end

RegisterNetEvent('nyx:playerLoaded', function(data)
    Nyx.PlayerData = data or {}
    Nyx.Ready = true
    TriggerEvent('nyx:client:playerLoaded', Nyx.PlayerData)
    NyxShared.Debug('Player data loaded')
end)

RegisterNetEvent('nyx:player:setJob', function(job)
    Nyx.PlayerData.job = job
    TriggerEvent('nyx:client:setJob', job)
end)

RegisterNetEvent('nyx:player:setGroup', function(group)
    Nyx.PlayerData.group = group
    TriggerEvent('nyx:client:setGroup', group)
end)

RegisterNetEvent('nyx:player:setAccount', function(account, amount)
    Nyx.PlayerData.accounts = Nyx.PlayerData.accounts or {}
    Nyx.PlayerData.accounts[account] = amount
    TriggerEvent('nyx:client:setAccount', account, amount)
end)

RegisterNetEvent('nyx:player:setMeta', function(key, value)
    Nyx.PlayerData.metadata = Nyx.PlayerData.metadata or {}
    Nyx.PlayerData.metadata[key] = value
    TriggerEvent('nyx:client:setMeta', key, value)
end)

RegisterNetEvent('nyx:notify', function(payload)
    if type(payload) == 'table' then
        Nyx.Notify(payload)
    else
        Nyx.Notify(tostring(payload or ''))
    end
end)

CreateThread(function()
    Wait(1000)
    TriggerServerEvent('nyx:requestPlayerData')
end)

AddEventHandler('nyx:getSharedObject', function(cb)
    if type(cb) == 'function' then cb(Nyx) end
end)

exports('GetCoreObject', function()
    return Nyx
end)

exports('GetPlayerData', function()
    return Nyx.GetPlayerData()
end)

exports('Notify', function(message, notifyType, duration, title)
    return Nyx.Notify(message, notifyType, duration, title)
end)
