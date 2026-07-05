NyxPlayer = {}
NyxPlayer.__index = NyxPlayer

function NyxPlayer:new(source, identifier, name)
    local self = setmetatable({}, NyxPlayer)
    self.source = tonumber(source)
    self.identifier = tostring(identifier or ('source:%s'):format(source))
    self.name = NyxShared.SafeString(name or GetPlayerName(source), ('Player %s'):format(source))
    self.group = Config.DefaultGroup
    self.job = NyxShared.Clone(Config.DefaultJob)
    self.accounts = NyxShared.Clone(Config.DefaultAccounts)
    self.metadata = {}
    self.variables = {}
    return self
end

function NyxPlayer:getSource() return self.source end
function NyxPlayer:getIdentifier() return self.identifier end
function NyxPlayer:getName() return self.name end
function NyxPlayer:getGroup() return self.group end

function NyxPlayer:setGroup(group)
    self.group = NyxShared.SafeString(group, Config.DefaultGroup)
    TriggerClientEvent('nyx:player:setGroup', self.source, self.group)
    if Config.UseStateBags then Player(self.source).state:set('nyx:group', self.group, true) end
    TriggerEvent('nyx:player:setGroup', self.source, self.group)
end

function NyxPlayer:getJob() return self.job end

function NyxPlayer:setJob(name, grade, label, gradeLabel, salary)
    name = NyxShared.SafeString(name, 'unemployed')
    self.job = {
        name = name,
        label = NyxShared.SafeString(label, name),
        grade = tonumber(grade) or 0,
        grade_label = NyxShared.SafeString(gradeLabel, 'None'),
        salary = tonumber(salary) or 0
    }

    TriggerClientEvent('nyx:player:setJob', self.source, self.job)
    if Config.UseStateBags then Player(self.source).state:set('nyx:job', self.job, true) end
    TriggerEvent('nyx:player:setJob', self.source, self.job)
end

function NyxPlayer:getAccount(account)
    return self.accounts[tostring(account or '')]
end

function NyxPlayer:getAccounts()
    return self.accounts
end

function NyxPlayer:setAccountMoney(account, amount)
    account = NyxShared.SafeString(account)
    amount = NyxShared.RoundMoney(amount)
    if account == '' or not amount or amount < 0 then return false end

    self.accounts[account] = amount
    TriggerClientEvent('nyx:player:setAccount', self.source, account, amount)
    TriggerEvent('nyx:player:setAccount', self.source, account, amount)
    return true
end

function NyxPlayer:addAccountMoney(account, amount)
    amount = NyxShared.RoundMoney(amount)
    if not amount or amount <= 0 then return false end
    return self:setAccountMoney(account, (tonumber(self:getAccount(account)) or 0) + amount)
end

function NyxPlayer:removeAccountMoney(account, amount)
    amount = NyxShared.RoundMoney(amount)
    if not amount or amount <= 0 then return false end
    local current = tonumber(self:getAccount(account)) or 0
    if current < amount then return false end
    return self:setAccountMoney(account, current - amount)
end

-- ESX-style aliases.
function NyxPlayer:getMoney() return self:getAccount('money') or 0 end
function NyxPlayer:addMoney(amount) return self:addAccountMoney('money', amount) end
function NyxPlayer:removeMoney(amount) return self:removeAccountMoney('money', amount) end
function NyxPlayer:setMoney(amount) return self:setAccountMoney('money', amount) end

function NyxPlayer:setMeta(key, value)
    if type(key) ~= 'string' or key == '' then return false end
    self.metadata[key] = value
    TriggerClientEvent('nyx:player:setMeta', self.source, key, value)
    TriggerEvent('nyx:player:setMeta', self.source, key, value)
    return true
end

function NyxPlayer:getMeta(key)
    return self.metadata[key]
end

function NyxPlayer:set(key, value)
    if type(key) ~= 'string' or key == '' then return false end
    self.variables[key] = value
    return true
end

function NyxPlayer:get(key)
    return self.variables[key]
end

function NyxPlayer:showNotification(message, notifyType, duration)
    TriggerClientEvent('nyx:notify', self.source, {
        message = tostring(message or ''),
        type = notifyType or Config.Notify.DefaultType,
        duration = duration or Config.Notify.DefaultDuration
    })
end

function NyxPlayer:toClient()
    return {
        source = self.source,
        identifier = self.identifier,
        name = self.name,
        group = self.group,
        job = NyxShared.Clone(self.job),
        accounts = NyxShared.Clone(self.accounts),
        metadata = NyxShared.Clone(self.metadata)
    }
end
