Nyx = Nyx or {}
Nyx.Players = Nyx.Players or {}
Nyx.PlayersByIdentifier = Nyx.PlayersByIdentifier or {}
Nyx.ServerCallbacks = Nyx.ServerCallbacks or {}
Nyx.ClientCallbacks = Nyx.ClientCallbacks or {}
Nyx.ClientCallbackId = 0
Nyx.RegisteredCommands = Nyx.RegisteredCommands or {}
Nyx.CommandCooldowns = Nyx.CommandCooldowns or {}
Nyx.CallbackCooldowns = Nyx.CallbackCooldowns or {}

local function getIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    local byType = {}

    for _, identifier in ipairs(identifiers) do
        local idType = identifier:match('([^:]+):')
        if idType then byType[idType] = identifier end
    end

    for _, idType in ipairs(Config.IdentifierPriority) do
        if byType[idType] then return byType[idType] end
    end

    return identifiers[1] or ('source:%s'):format(source)
end

function Nyx.GetPlayerFromId(source)
    return Nyx.Players[tonumber(source)]
end

function Nyx.GetPlayerFromIdentifier(identifier)
    return Nyx.PlayersByIdentifier[tostring(identifier or '')]
end

function Nyx.GetPlayers()
    return Nyx.Players
end

function Nyx.GetExtendedPlayers(key, value)
    local list = {}

    for _, player in pairs(Nyx.Players) do
        if not key then
            list[#list + 1] = player
        elseif key == 'job' and player:getJob().name == value then
            list[#list + 1] = player
        elseif player:get(key) == value then
            list[#list + 1] = player
        end
    end

    return list
end

function Nyx.GetCoreObject()
    return Nyx
end

local function syncStateBag(player)
    if not Config.UseStateBags or not player or not player.source then return end
    local state = Player(player.source).state
    state:set('nyx:loaded', true, true)
    state:set('nyx:identifier', player.identifier, true)
    state:set('nyx:job', player.job, true)
    state:set('nyx:group', player.group, true)
end

function Nyx.LoadPlayer(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end

    local identifier = getIdentifier(source)
    local existing = Nyx.Players[source]
    if existing then return existing end

    local player = NyxPlayer:new(source, identifier, GetPlayerName(source))
    Nyx.Players[source] = player
    Nyx.PlayersByIdentifier[identifier] = player

    syncStateBag(player)
    TriggerClientEvent('nyx:playerLoaded', source, player:toClient())
    TriggerEvent('nyx:playerLoaded', source, player)
    NyxShared.Debug(('Loaded %s (%s)'):format(player:getName(), identifier))
    return player
end

local function unloadPlayer(source, reason)
    source = tonumber(source)
    local player = Nyx.Players[source]
    if not player then return end

    TriggerEvent('nyx:playerDropped', source, player, reason)
    NyxShared.Debug(('Dropped %s: %s'):format(player:getName(), reason or 'unknown'))

    if Config.UseStateBags then
        Player(source).state:set('nyx:loaded', false, true)
    end

    Nyx.PlayersByIdentifier[player.identifier] = nil
    Nyx.Players[source] = nil
    Nyx.CommandCooldowns[source] = nil
    Nyx.CallbackCooldowns[source] = nil
end

AddEventHandler('playerJoining', function()
    Nyx.LoadPlayer(source)
end)

AddEventHandler('playerDropped', function(reason)
    unloadPlayer(source, reason)
end)

CreateThread(function()
    Wait(500)

    for _, id in ipairs(GetPlayers()) do
        Nyx.LoadPlayer(tonumber(id))
    end

    print(('^2[Nyx_Core]^7 %s v%s'):format(_U('core_ready'), Config.Version))
end)

RegisterNetEvent('nyx:requestPlayerData', function()
    local src = source
    local player = Nyx.GetPlayerFromId(src) or Nyx.LoadPlayer(src)
    if player then
        TriggerClientEvent('nyx:playerLoaded', src, player:toClient())
    end
end)

AddEventHandler('nyx:getSharedObject', function(cb)
    if type(cb) == 'function' then cb(Nyx) end
end)

exports('GetCoreObject', function()
    return Nyx
end)
