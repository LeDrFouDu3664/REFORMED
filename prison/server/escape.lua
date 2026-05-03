RegisterNetEvent("prison:server:executeEscape")
AddEventHandler("prison:server:executeEscape", function()
    local _source = source
    local identifier = GetPlayerIdentifier(_source)
    if not identifier then return end

    -- Secure Validation
    if not serverEscapeTools or not serverEscapeTools[_source] then
        print(("[Prison] Exploit évasion détecté par l'ID %s."):format(_source))
        return
    end

    -- Consume server tool state
    serverEscapeTools[_source] = nil

    -- Clear jail time locally and in the database to properly release the player
    if GetFramework() == "esx" then
        MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        })
        TriggerClientEvent('prison:client:release', _source)
        TriggerClientEvent('chat:addMessage', _source, { args = { '^1[Évasion]', 'Vous vous êtes évadé ! Fuyez !' } })
    elseif GetFramework() == "qbcore" then
        local Player = QBCore.Functions.GetPlayer(_source)
        if Player then
            Player.Functions.SetMetaData("injail", 0)
            Player.Functions.Save()
            TriggerClientEvent('prison:client:release', _source)
            TriggerClientEvent('chat:addMessage', _source, { args = { '^1[Évasion]', 'Vous vous êtes évadé ! Fuyez !' } })
        end
    end

    -- Notify Guards/Police
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local job = GetPlayerJob(playerId)
        local isGuard = false
        for _, gJob in ipairs(Config.GuardJobs) do
            if job == gJob then
                isGuard = true
                break
            end
        end
        if isGuard then
            TriggerClientEvent('chat:addMessage', playerId, { args = { '^1[Alerte Prison]', 'Une évasion est en cours !' } })
        end
    end
end)
