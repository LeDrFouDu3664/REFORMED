ESX = exports["es_extended"]:getSharedObject()

local isJailed = false
local jailTime = 0

-- Blip sur la carte
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
    SetBlipSprite(blip, 188)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Prison d'État")
    EndTextCommandSetBlipName(blip)
end)

-- Événement d'emprisonnement
RegisterNetEvent('prison:client:JailPlayer')
AddEventHandler('prison:client:JailPlayer', function(time)
    local wasAlreadyJailed = isJailed
    isJailed = true
    jailTime = time

    -- Téléportation en prison et retrait des armes
    SetEntityCoords(PlayerPedId(), Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
    RemoveAllPedWeapons(PlayerPedId(), true)
    TriggerEvent('esx:showNotification', 'Vous avez été emprisonné pour ' .. jailTime .. ' mois.')

    -- Boucle de prison
    if not wasAlreadyJailed then
        Citizen.CreateThread(function()
            while isJailed do
                Citizen.Wait(1000)
                jailTime = jailTime - 1

                local pedCoords = GetEntityCoords(PlayerPedId())
                local dist = #(pedCoords - Config.PrisonCoords)

                -- Anti-évasion
                if dist > Config.PrisonRadius then
                    SetEntityCoords(PlayerPedId(), Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
                    TriggerEvent('esx:showNotification', 'Vous ne pouvez pas vous échapper !')
                end

                -- Fin de peine
                if jailTime <= 0 then
                    isJailed = false
                    TriggerServerEvent('prison:server:FinishJail')
                end
            end
        end)
    end
end)

-- Événement de libération
RegisterNetEvent('prison:client:UnjailPlayer')
AddEventHandler('prison:client:UnjailPlayer', function()
    isJailed = false
    jailTime = 0
    SetEntityCoords(PlayerPedId(), Config.ReleaseCoords.x, Config.ReleaseCoords.y, Config.ReleaseCoords.z)
    TriggerEvent('esx:showNotification', 'Vous êtes libre ! Essayez de rester dans le droit chemin.')
end)

-- Actualisation du temps par les travaux
RegisterNetEvent('prison:client:ReduceJailTime')
AddEventHandler('prison:client:ReduceJailTime', function(amount)
    if isJailed and jailTime > 0 then
        jailTime = jailTime - amount
        if jailTime < 0 then jailTime = 0 end
    end
end)

-- Command pour l'emploi du temps
RegisterCommand('emploi_du_temps', function()
    if isJailed then
        local msg = "~y~Emploi du temps de la Prison d'État~s~\n"
        for i=0, 23 do
            if Config.Schedule[i] then
                msg = msg .. "~b~" .. i .. "h00~s~ : " .. Config.Schedule[i] .. "\n"
            end
        end
        TriggerEvent('chat:addMessage', {
            color = {255, 165, 0},
            multiline = true,
            args = {"Système", msg}
        })
    else
        TriggerEvent('esx:showNotification', 'Vous n\'êtes pas en prison.')
    end
end, false)

-- Suivi de l'heure en jeu pour l'emploi du temps
Citizen.CreateThread(function()
    local lastHour = -1
    while true do
        Citizen.Wait(1000)
        if isJailed then
            local currentHour = GetClockHours()
            if currentHour ~= lastHour then
                lastHour = currentHour
                if Config.Schedule[currentHour] then
                    TriggerEvent('esx:showNotification', '~b~['..currentHour..'h00]~s~ ' .. Config.Schedule[currentHour])
                end
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

-- Fonction pour jouer l'animation de travail
local isWorking = false
function StartPrisonWork(jobName)
    if isWorking then return end
    isWorking = true

    local jobData = Config.PrisonerJobs[jobName]
    local ped = PlayerPedId()

    RequestAnimDict(jobData.Anim.dict)
    local timeout = 0
    while not HasAnimDictLoaded(jobData.Anim.dict) and timeout < 1000 do
        Citizen.Wait(10)
        timeout = timeout + 10
    end

    if HasAnimDictLoaded(jobData.Anim.dict) then
        TaskPlayAnim(ped, jobData.Anim.dict, jobData.Anim.name, 8.0, -8.0, 10000, 1, 0, false, false, false)
        TriggerEvent('esx:showNotification', 'Vous commencez à travailler...')
        Citizen.Wait(10000)
        ClearPedTasks(ped)
        TriggerServerEvent('prison:server:RewardPrisoner', jobName)
    else
        TriggerEvent('esx:showNotification', '~r~Erreur de chargement de l\'animation.')
    end

    isWorking = false
end

-- Fonction pour ouvrir le coffre de prison
function OpenPrisonStash()
    if Config.InventorySystem == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', {id = 'prison_stash'})
    else
        -- Fallback ESX standard
        TriggerEvent('esx:showNotification', '~r~Le système d\'inventaire ESX n\'est pas configuré pour les coffres. Utilisez ox_inventory.')
    end
end

-- Interactions des métiers (Garde, EMS) et Travaux des Prisonniers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local sleep = true

        -- Interaction Garde : Armurerie
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.Jobs.Garde then
            local dist = #(pedCoords - Config.Locations.Armory)
            if dist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Armory.x, Config.Locations.Armory.y, Config.Locations.Armory.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 150, 255, 100, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour ouvrir l\'armurerie')
                    if IsControlJustReleased(0, 38) then -- Touche E
                        TriggerServerEvent('prison:server:GiveGuardWeapons')
                        TriggerEvent('esx:showNotification', 'Vous avez récupéré votre équipement de garde.')
                    end
                end
            end
        end

        -- Interaction EMS : Infirmerie
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.Jobs.EMS then
            local dist = #(pedCoords - Config.Locations.Infirmary)
            if dist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Infirmary.x, Config.Locations.Infirmary.y, Config.Locations.Infirmary.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour prendre votre service médical')
                    if IsControlJustReleased(0, 38) then -- Touche E
                        TriggerEvent('esx:showNotification', 'Vous êtes maintenant en position pour soigner les détenus.')
                        -- (Tu peux ajouter ton script de soin EMS ici)
                    end
                end
            end
        end

        -- Interactions des prisonniers (Travaux)
        if isJailed and not isWorking then
            for jobName, jobData in pairs(Config.PrisonerJobs) do
                for _, coord in pairs(jobData.Coords) do
                    local dist = #(pedCoords - coord)
                    if dist < 10.0 then
                        sleep = false
                        DrawMarker(20, coord.x, coord.y, coord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
                        if dist < 1.5 then
                            ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour travailler (' .. jobName .. ')')
                            if IsControlJustReleased(0, 38) then
                                StartPrisonWork(jobName)
                            end
                        end
                    end
                end
            end

            -- Stash pour les prisonniers
            local stashDist = #(pedCoords - Config.Locations.PrisonerStash)
            if stashDist < 10.0 then
                sleep = false
                DrawMarker(2, Config.Locations.PrisonerStash.x, Config.Locations.PrisonerStash.y, Config.Locations.PrisonerStash.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                if stashDist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour ouvrir vos effets personnels')
                    if IsControlJustReleased(0, 38) then
                        OpenPrisonStash()
                    end
                end
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)
