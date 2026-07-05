exports('GetPlayerFromId', function(source)
    return Nyx.GetPlayerFromId(source)
end)

exports('GetPlayerFromIdentifier', function(identifier)
    return Nyx.GetPlayerFromIdentifier(identifier)
end)

exports('GetPlayers', function()
    return Nyx.GetPlayers()
end)

exports('GetExtendedPlayers', function(key, value)
    return Nyx.GetExtendedPlayers(key, value)
end)
