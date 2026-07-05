NyxShared = NyxShared or {}

function NyxShared.Trim(value)
    return tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

function NyxShared.Clone(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do out[NyxShared.Clone(k)] = NyxShared.Clone(v) end
    return out
end

function NyxShared.RoundMoney(value)
    local n = tonumber(value)
    if not n then return nil end
    return math.floor(n)
end

function NyxShared.SafeString(value, fallback)
    value = NyxShared.Trim(value)
    if value == '' then return fallback or '' end
    return value
end

function NyxShared.Debug(...)
    if Config and Config.Debug then
        print('^5[Nyx_Core]^7', ...)
    end
end
