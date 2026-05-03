RegisterCommand("searchprisoner", function()
    local job = GetPlayerJob()
    local isGuard = false
    for _, gJob in ipairs(Config.GuardJobs) do
        if job == gJob then
            isGuard = true
            break
        end
    end

    if isGuard then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance <= 3.0 then
            -- Open inventory (example using ox_inventory)
            -- TriggerServerEvent("prison:server:searchPlayer", GetPlayerServerId(player))
            -- To keep simple, using export for ox_inventory if available
            local success, _ = pcall(function()
                exports.ox_inventory:openInventory('player', GetPlayerServerId(player))
            end)
            if not success then
                print("[Prison] ox_inventory introuvable pour la fouille.")
            end
        else
            -- ShowNotification("Aucun joueur à proximité.")
        end
    end
end, false)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local plyPed = PlayerPedId()
    local plyCoords = GetEntityCoords(plyPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= plyPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(plyCoords - targetCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end
