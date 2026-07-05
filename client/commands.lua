RegisterCommand('nyxrefresh', function()
    TriggerServerEvent('nyx:requestPlayerData')
    Nyx.Notify('Requested fresh player data.', 'info')
end, false)

RegisterCommand('nyxtestnotify', function()
    Nyx.Notify('Nyx_Core NUI notification is working.', 'success')
end, false)
