local helperPeds = {}

Citizen.CreateThread(function()
    -- Attendre un peu que le joueur soit chargé
    Citizen.Wait(2000)

    for i, data in ipairs(Config.Locations.Helpers) do
        local modelHash = GetHashKey(data.model)

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end

        -- Spawn le PNJ (-1.0 sur l'axe Z pour corriger la hauteur de spawn)
        local ped = CreatePed(4, modelHash, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)

        -- Rendre le PNJ statique, invincible et passif
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetPedCombatAttributes(ped, 17, 0)

        table.insert(helperPeds, ped)
    end
end)

-- Optionnel: Si la ressource est redémarrée, on supprime les vieux PNJ pour éviter les doublons
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for _, ped in ipairs(helperPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
