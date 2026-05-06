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

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _, data in ipairs(Config.Locations.Helpers) do
            local dist = #(pos - data.coords)
            if dist < 2.0 then
                sleep = 0
                SetTextComponentFormat("STRING")
                AddTextComponentString("Appuyez sur ~INPUT_CONTEXT~ pour parler à " .. data.name)
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustReleased(0, 38) then
                    if data.id == "accueil" then
                        TriggerEvent("chat:addMessage", { args = { '^5['..data.name..']', 'Bienvenue à la prison fédérale. Restez calme.' } })
                    elseif data.id == "armurerie" then
                        local job = GetPlayerJob()
                        local isGuard = false
                        for _, gJob in ipairs(Config.GuardJobs) do
                            if job == gJob then
                                isGuard = true
                                break
                            end
                        end
                        if isGuard then
                            TriggerEvent("chat:addMessage", { args = { '^5['..data.name..']', 'Voici votre équipement, officier.' } })
                            -- Logic to open armory or give weapons
                        else
                            TriggerEvent("chat:addMessage", { args = { '^5['..data.name..']', 'L\'armurerie est réservée au personnel autorisé.' } })
                        end
                    elseif data.id == "atelier" then
                        TriggerServerEvent("prison:server:requestMission", data.id)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
