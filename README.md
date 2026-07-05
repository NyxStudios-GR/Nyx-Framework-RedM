# Nyx_Core v0.2.0

Modern standalone RedM/Cfx.re core object inspired by ESX patterns from fivem. This update keeps the old `0.1.0` exports/events and adds safer callbacks, ACE-aware commands, state bags, cleaner player helpers, and polished NUI notifications.


## Install

1. Replace your old `Nyx_Core` folder with this one.
2. Add this to `server.cfg`:

```cfg
ensure chat
ensure Nyx_Core
```

3. Optional ACE permissions:

```cfg
add_ace group.admin nyx.admin allow
add_ace group.admin command.nyxsetjob allow
add_ace group.admin command.nyxaddmoney allow
```

4. Start server and check console for:

```txt
[Nyx_Core] Το Nyx_Core είναι έτοιμο v0.2.0
```

## Server usage

```lua
local Nyx = exports['Nyx_Core']:GetCoreObject()

RegisterCommand('myinfo', function(source)
    local xPlayer = Nyx.GetPlayerFromId(source)
    if not xPlayer then return end

    print(xPlayer:getName(), xPlayer:getIdentifier(), xPlayer:getJob().name)
end)
```

## Client usage

```lua
local Nyx = exports['Nyx_Core']:GetCoreObject()

RegisterCommand('myjob', function()
    local data = Nyx.GetPlayerData()
    Nyx.Notify(('Job: %s'):format(data.job and data.job.name or 'none'), 'info')
end)
```

## Callbacks

### Server callback

```lua
local Nyx = exports['Nyx_Core']:GetCoreObject()

Nyx.RegisterServerCallback('myres:getSomething', function(source, cb)
    cb({ ok = true, source = source })
end)
```

### Client call

```lua
local Nyx = exports['Nyx_Core']:GetCoreObject()

Nyx.TriggerServerCallback('myres:getSomething', function(data, err)
    if err then return print('Callback failed:', err) end
    print(json.encode(data))
end)
```

### Server to client callback

```lua
local Nyx = exports['Nyx_Core']:GetCoreObject()

Nyx.TriggerClientCallback(source, 'myres:getClientState', function(data, err)
    print(json.encode(data), err)
end)
```

## Player methods

```lua
xPlayer:getSource()
xPlayer:getIdentifier()
xPlayer:getName()
xPlayer:getGroup()
xPlayer:setGroup(group)
xPlayer:getJob()
xPlayer:setJob(name, grade, label, gradeLabel, salary)
xPlayer:getAccount(account)
xPlayer:getAccounts()
xPlayer:setAccountMoney(account, amount)
xPlayer:addAccountMoney(account, amount)
xPlayer:removeAccountMoney(account, amount)
xPlayer:getMoney()
xPlayer:setMoney(amount)
xPlayer:addMoney(amount)
xPlayer:removeMoney(amount)
xPlayer:setMeta(key, value)
xPlayer:getMeta(key)
xPlayer:set(key, value)
xPlayer:get(key)
xPlayer:showNotification(message, type, duration)
xPlayer:toClient()
```

## Built-in debug commands

```txt
/nyxinfo
/nyxrefresh
/nyxtestnotify
/nyxsetjob [id] [job] [grade]
/nyxaddmoney [id] [amount]
```

Disable them in `shared/config.lua`:

```lua
Config.EnableDebugCommands = false
```

## What changed from 0.1.0

- Version bumped to `0.2.0`.
- Added NUI toast notification system.
- Added callback timeout/rate limiting and duplicate-response guard.
- Added server-to-client callbacks.
- Added ACE permission checks with fallback to internal groups.
- Added player lookup by identifier.
- Added ESX-style money aliases.
- Added state bags: `nyx:loaded`, `nyx:identifier`, `nyx:job`, `nyx:group`.
- Added Greek locale by default.
- Improved validation and defensive cloning to avoid shared table mutation.
- Kept old events/exports: `nyx:getSharedObject`, `GetCoreObject`, `GetPlayerData`, `TriggerServerCallback`, `RegisterClientCallback`.

## Troubleshooting

- **Resource not starting:** confirm folder name is exactly `Nyx_Core` and `fxmanifest.lua` is at the root.
- **NUI not showing:** make sure the `ui/` files exist and `ui_page 'ui/index.html'` is in `fxmanifest.lua`.
- **No chat suggestions:** start `chat` before `Nyx_Core`.
- **Admin commands denied:** add ACE permissions or set the player's group with `xPlayer:setGroup('admin')`.
- **Player data nil on client:** wait for `nyx:client:playerLoaded` or call `/nyxrefresh`.
- **Old cached UI:** restart resource and clear client cache if needed.
