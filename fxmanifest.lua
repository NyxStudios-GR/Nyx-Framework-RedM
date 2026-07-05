fx_version 'cerulean'
games { 'rdr3' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources may become incompatible.'

author 'DekSS / Developer'
description 'Nyx_Core - our framework for your redm server finally launched!! Updates Every'
version '0.2.0'
lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

shared_scripts {
    'shared/config.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

server_scripts {
    'server/main.lua',
    'server/player.lua',
    'server/callbacks.lua',
    'server/commands.lua',
    'server/exports.lua'
}

client_scripts {
    'client/main.lua',
    'client/callbacks.lua',
    'client/commands.lua'
}

exports {
    'GetCoreObject',
    'GetPlayerData',
    'TriggerServerCallback',
    'RegisterClientCallback',
    'Notify'
}

server_exports {
    'GetCoreObject',
    'GetPlayerFromId',
    'GetPlayerFromIdentifier',
    'GetPlayers',
    'GetExtendedPlayers',
    'RegisterServerCallback',
    'TriggerClientCallback',
    'RegisterCommand'
}
