local function hasPermission(source, group, commandName)
    if source == 0 then return true end

    group = group or Config.DefaultGroup
    if group == 'user' then return true end

    if Config.UseAcePermissions then
        if IsPlayerAceAllowed(source, ('command.%s'):format(commandName)) then return true end
        if IsPlayerAceAllowed(source, 'nyx.admin') then return true end
        if IsPlayerAceAllowed(source, ('nyx.group.%s'):format(group)) then return true end
    end

    local player = Nyx.GetPlayerFromId(source)
    if not player then return false end

    local playerGroup = player:getGroup()
    if Config.AdminGroups[playerGroup] then return true end
    return playerGroup == group
end

local function addSuggestion(name, suggestion)
    if not Config.RegisterChatSuggestions or not suggestion then return end

    TriggerClientEvent('chat:addSuggestion', -1, '/' .. name, suggestion.help or '', suggestion.arguments or {})
end

function Nyx.RegisterCommand(name, group, cb, suggestion)
    assert(type(name) == 'string' and name ~= '', 'command name must be string')
    assert(type(cb) == 'function', 'command callback must be function')

    Nyx.RegisteredCommands[name] = { group = group or 'user', cb = cb, suggestion = suggestion }
    addSuggestion(name, suggestion)

    RegisterCommand(name, function(source, args, raw)
        local now = GetGameTimer()
        Nyx.CommandCooldowns[source] = Nyx.CommandCooldowns[source] or {}

        local last = Nyx.CommandCooldowns[source][name] or 0
        if source ~= 0 and now - last < Config.CommandCooldownMs then
            TriggerClientEvent('nyx:notify', source, { message = _U('command_wait'), type = 'warning' })
            return
        end

        Nyx.CommandCooldowns[source][name] = now

        if not hasPermission(source, group, name) then
            TriggerClientEvent('nyx:notify', source, { message = _U('no_permission'), type = 'error' })
            return
        end

        local player = source ~= 0 and Nyx.GetPlayerFromId(source) or nil
        local ok, err = pcall(cb, player, args or {}, raw or '', source)
        if not ok then
            print(('^1[Nyx_Core]^7 Command /%s failed: %s'):format(name, err))
        end
    end, false)
end

if Config.EnableDebugCommands then
    Nyx.RegisterCommand('nyxinfo', 'user', function(player, args, raw, source)
        if source == 0 then
            print(('[Nyx_Core] Online players: %s'):format(#GetPlayers()))
            return
        end

        player:showNotification(('ID: %s | Job: %s | Cash: $%s'):format(
            player:getIdentifier(),
            player:getJob().name,
            player:getAccount('money') or 0
        ), 'info')
    end, { help = 'Show your Nyx_Core info' })

    Nyx.RegisterCommand('nyxsetjob', 'admin', function(player, args, raw, source)
        local target = tonumber(args[1])
        local job = args[2]
        local grade = tonumber(args[3]) or 0
        local xTarget = Nyx.GetPlayerFromId(target)

        if not xTarget or not job then
            if source ~= 0 then player:showNotification('Usage: /nyxsetjob [id] [job] [grade]', 'error') end
            return
        end

        xTarget:setJob(job, grade, job, tostring(grade), 0)
        xTarget:showNotification(('Job set to %s grade %s'):format(job, grade), 'success')
    end, {
        help = 'Set player job',
        arguments = {
            { name = 'id', help = 'Server ID' },
            { name = 'job', help = 'Job name' },
            { name = 'grade', help = 'Grade' }
        }
    })

    Nyx.RegisterCommand('nyxaddmoney', 'admin', function(player, args, raw, source)
        local target = tonumber(args[1])
        local amount = tonumber(args[2])
        local xTarget = Nyx.GetPlayerFromId(target)

        if not xTarget or not amount or amount <= 0 then
            if source ~= 0 then player:showNotification('Usage: /nyxaddmoney [id] [amount]', 'error') end
            return
        end

        xTarget:addAccountMoney('money', amount)
        xTarget:showNotification(('$%s added'):format(math.floor(amount)), 'success')
    end, {
        help = 'Add cash to a player',
        arguments = {
            { name = 'id', help = 'Server ID' },
            { name = 'amount', help = 'Amount' }
        }
    })
end

exports('RegisterCommand', function(name, group, cb, suggestion)
    return Nyx.RegisterCommand(name, group, cb, suggestion)
end)
