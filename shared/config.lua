Config = {}

Config.Debug = true
Config.Locale = 'el'
Config.Version = '0.2.0'
Config.ResourceName = 'Nyx_Core'

-- Identifier priority. RedM commonly has license/steam/discord depending on server setup.
Config.IdentifierPriority = { 'license', 'steam', 'discord', 'fivem' }

Config.DefaultGroup = 'user'
Config.AdminGroups = {
    admin = true,
    superadmin = true,
    owner = true
}

Config.DefaultJob = {
    name = 'unemployed',
    label = 'Unemployed',
    grade = 0,
    grade_label = 'None',
    salary = 0
}

Config.DefaultAccounts = {
    money = 0,
    bank = 0,
    gold = 0
}

-- Command protection.
Config.CommandCooldownMs = 1000
Config.EnableDebugCommands = true
Config.UseAcePermissions = true -- allows ace: command.nyxsetjob / nyx.admin
Config.RegisterChatSuggestions = true

-- Callback protection.
Config.CallbackCooldownMs = 150
Config.CallbackTimeoutMs = 15000

-- Notification UI.
Config.Notify = {
    UseNui = true,
    DefaultType = 'info',
    DefaultDuration = 4500,
    MaxQueue = 6
}

-- Optional state bags for other resources. Safe to keep enabled.
Config.UseStateBags = true
