local tutorialPlayed = {}

RegisterNetEvent("prison:server:checkTutorial")
AddEventHandler("prison:server:checkTutorial", function()
    local _source = source
    local identifier = GetPlayerIdentifier(_source)
    if not identifier then return end

    if not tutorialPlayed[identifier] then
        -- In a fully persistent script, this would be saved in a database column.
        -- For this iteration, we use a simple session-based cache.
        tutorialPlayed[identifier] = true
        TriggerClientEvent("prison:client:showTutorial", _source)
    end
end)

-- You can hook this into framework loaded events
if GetFramework() == "esx" then
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
        -- Add slight delay to ensure UI mounts
        Citizen.SetTimeout(5000, function()
            -- You can optionally check here if xPlayer is a prisoner
            -- then trigger the check
            TriggerEvent("prison:server:checkTutorial", playerId)
        end)
    end)
elseif GetFramework() == "qbcore" then
    RegisterNetEvent("QBCore:Server:PlayerLoaded")
    AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
        if Player and Player.PlayerData then
            local playerId = Player.PlayerData.source
            Citizen.SetTimeout(5000, function()
                TriggerEvent("prison:server:checkTutorial", playerId)
            end)
        end
    end)
end
