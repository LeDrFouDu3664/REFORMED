if GetFramework() == "esx" then
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
        Citizen.SetTimeout(2000, function()
            local identifier = GetPlayerIdentifier(playerId)
            if identifier then
                MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
                    ['@identifier'] = identifier
                }, function(result)
                    if result[1] and result[1].jail_time and tonumber(result[1].jail_time) > 0 then
                        TriggerClientEvent("prison:client:jailLogin", playerId, tonumber(result[1].jail_time))
                    end
                end)
            end
        end)
    end)
elseif GetFramework() == "qbcore" then
    RegisterNetEvent("QBCore:Server:PlayerLoaded")
    AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
        if Player and Player.PlayerData then
            local playerId = Player.PlayerData.source
            Citizen.SetTimeout(2000, function()
                local time = Player.PlayerData.metadata["injail"] or 0
                if time > 0 then
                    TriggerClientEvent("prison:client:jailLogin", playerId, time)
                end
            end)
        end
    end)
end

-- Double-character sync hook (17mov_Character compatibility)
RegisterNetEvent("17mov_Character:characterLoaded")
AddEventHandler("17mov_Character:characterLoaded", function(source, charData)
    local _source = source
    local identifier = GetPlayerIdentifier(_source)
    if not identifier then return end

    Citizen.SetTimeout(2000, function()
        if GetFramework() == "esx" then
            MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            }, function(result)
                if result[1] and result[1].jail_time and tonumber(result[1].jail_time) > 0 then
                    TriggerClientEvent("prison:client:jailLogin", _source, tonumber(result[1].jail_time))
                end
            end)
        elseif GetFramework() == "qbcore" then
            local Player = QBCore.Functions.GetPlayer(_source)
            if Player then
                local time = Player.PlayerData.metadata["injail"] or 0
                if time > 0 then
                    TriggerClientEvent("prison:client:jailLogin", _source, time)
                end
            end
        end
    end)
end)

-- Passive Jail Timer Loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every 1 minute

        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local identifier = GetPlayerIdentifier(playerId)
            if identifier then
                if GetFramework() == "esx" then
                    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
                        ['@identifier'] = identifier
                    }, function(result)
                        if result[1] and result[1].jail_time then
                            local currentJailTime = tonumber(result[1].jail_time)
                            if currentJailTime > 0 then
                                ReducePlayerJailTime(playerId, identifier, 1)
                            end
                        end
                    end)
                elseif GetFramework() == "qbcore" then
                    local Player = QBCore.Functions.GetPlayer(playerId)
                    if Player then
                        local time = Player.PlayerData.metadata["injail"] or 0
                        if time > 0 then
                            ReducePlayerJailTime(playerId, identifier, 1)
                        end
                    end
                end
            end
        end
    end
end)
