Locales = {
    en = {
        core_ready = 'Nyx_Core ready',
        no_permission = 'You do not have permission.',
        player_not_found = 'Player not found.',
        invalid_amount = 'Invalid amount.',
        command_wait = 'Slow down before using this command again.',
        callback_wait = 'Slow down before using callbacks again.',
        player_loaded = 'Player loaded.'
    },
    el = {
        core_ready = 'Το Nyx_Core είναι έτοιμο',
        no_permission = 'Δεν έχεις δικαίωμα για αυτή την ενέργεια.',
        player_not_found = 'Ο παίκτης δεν βρέθηκε.',
        invalid_amount = 'Μη έγκυρο ποσό.',
        command_wait = 'Περίμενε λίγο πριν ξαναχρησιμοποιήσεις την εντολή.',
        callback_wait = 'Περίμενε λίγο πριν ξαναστείλεις callback.',
        player_loaded = 'Ο παίκτης φορτώθηκε.'
    }
}

function _U(key, ...)
    local locale = Config and Config.Locale or 'en'
    local value = Locales[locale] and Locales[locale][key] or Locales.en[key] or key
    if select('#', ...) > 0 then
        return string.format(value, ...)
    end
    return value
end
