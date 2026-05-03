-- This assumes 17mov_Character fires a specific event when a character is loaded/selected
-- e.g. "17mov_Character:characterLoaded"

RegisterNetEvent("17mov_Character:characterLoaded")
AddEventHandler("17mov_Character:characterLoaded", function(source, charData)
    local _source = source
    local identifier = GetPlayerIdentifier(_source)
    if not identifier then return end

    SyncCharacterJailStatus(identifier)
end)
