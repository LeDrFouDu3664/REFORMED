ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

local isJailed = false
local jailTime = 0

-- Blip global de la Prison
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

    -- Blips internes à la prison pour les interactions
    -- Armurerie Garde
    local armoryBlip = AddBlipForCoord(Config.Locations.Armory.x, Config.Locations.Armory.y, Config.Locations.Armory.z)
    SetBlipSprite(armoryBlip, 175)
    SetBlipScale(armoryBlip, 0.6)
    SetBlipColour(armoryBlip, 38)
    SetBlipAsShortRange(armoryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Armurerie Garde")
    EndTextCommandSetBlipName(armoryBlip)

    -- Infirmerie EMS
    local infBlip = AddBlipForCoord(Config.Locations.Infirmary.x, Config.Locations.Infirmary.y, Config.Locations.Infirmary.z)
    SetBlipSprite(infBlip, 153)
    SetBlipScale(infBlip, 0.6)
    SetBlipColour(infBlip, 1)
    SetBlipAsShortRange(infBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Infirmerie")
    EndTextCommandSetBlipName(infBlip)

    -- Coffre Prisonnier
    local stashBlip = AddBlipForCoord(Config.Locations.PrisonerStash.x, Config.Locations.PrisonerStash.y, Config.Locations.PrisonerStash.z)
    SetBlipSprite(stashBlip, 50)
    SetBlipScale(stashBlip, 0.6)
    SetBlipColour(stashBlip, 5)
    SetBlipAsShortRange(stashBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Effets Personnels")
    EndTextCommandSetBlipName(stashBlip)

    -- Blips des travaux
    for jobName, jobData in pairs(Config.PrisonerJobs) do
        for _, coord in pairs(jobData.Coords) do
            local jobBlip = AddBlipForCoord(coord.x, coord.y, coord.z)
            SetBlipSprite(jobBlip, 566)
            SetBlipScale(jobBlip, 0.5)
            SetBlipColour(jobBlip, 5)
            SetBlipAsShortRange(jobBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Travail : " .. jobName)
            EndTextCommandSetBlipName(jobBlip)
        end
    end
end)

-- Gestion de la densité des PNJ (Bloqués partout sauf en prison)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local distToPrison = #(pedCoords - Config.PrisonCoords)

        if distToPrison > Config.PrisonRadius then
            -- En dehors de la prison : Bloquer les PNJ et le trafic
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
        else
            -- Dans la prison : PNJ normaux
            SetPedDensityMultiplierThisFrame(1.0)
            SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
            SetVehicleDensityMultiplierThisFrame(1.0)
            SetRandomVehicleDensityMultiplierThisFrame(1.0)
            SetParkedVehicleDensityMultiplierThisFrame(1.0)
        end
    end
end)

-- Événement de Premier Spawn
-- Désactiver les PNJ qui attaquent et la police de GTA
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- Empêcher le niveau de recherche
        if GetPlayerWantedLevel(PlayerId()) > 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end

        -- Empêcher les PNJ de la prison d'attaquer les joueurs
        SetRelationshipBetweenGroups(1, GetHashKey("PRISONER"), GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(1, GetHashKey("PLAYER"), GetHashKey("PRISONER"))
        SetRelationshipBetweenGroups(1, GetHashKey("GUARD"), GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(1, GetHashKey("PLAYER"), GetHashKey("GUARD"))
    end
end)

-- Spawn des PNJs Statiques
local spawnedNPCs = {}
Citizen.CreateThread(function()
    -- Gardes d'aide
    for i=1, #Config.GuardNPCs do
        local v = Config.GuardNPCs[i]
        RequestModel(v.model)
        while not HasModelLoaded(v.model) do Citizen.Wait(10) end
        local ped = CreatePed(4, GetHashKey(v.model), v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, false, true)
        SetEntityHeading(ped, v.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedRelationshipGroupHash(ped, GetHashKey("GUARD"))
        table.insert(spawnedNPCs, {ped = ped, text = v.text})
    end

    -- PNJ de Quête
    RequestModel(Config.QuestNPC.Model)
    while not HasModelLoaded(Config.QuestNPC.Model) do Citizen.Wait(10) end
    local qped = CreatePed(4, GetHashKey(Config.QuestNPC.Model), Config.QuestNPC.Coords.x, Config.QuestNPC.Coords.y, Config.QuestNPC.Coords.z - 1.0, Config.QuestNPC.Coords.w, false, true)
    FreezeEntityPosition(qped, true)
    SetEntityInvincible(qped, true)
    SetBlockingOfNonTemporaryEvents(qped, true)
    SetPedRelationshipGroupHash(qped, GetHashKey("PRISONER"))
end)

-- Update Vendor Spawn
local currentVendorCoords = nil
local vendorPed = nil
RegisterNetEvent('prison:client:UpdateVendorSpawn')
AddEventHandler('prison:client:UpdateVendorSpawn', function(coords)
    currentVendorCoords = coords
    if vendorPed and DoesEntityExist(vendorPed) then DeleteEntity(vendorPed) end

    RequestModel(Config.BlackMarket.Model)
    while not HasModelLoaded(Config.BlackMarket.Model) do Citizen.Wait(10) end
    vendorPed = CreatePed(4, GetHashKey(Config.BlackMarket.Model), coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    FreezeEntityPosition(vendorPed, true)
    SetEntityInvincible(vendorPed, true)
    SetBlockingOfNonTemporaryEvents(vendorPed, true)
    SetPedRelationshipGroupHash(vendorPed, GetHashKey("PRISONER"))
end)

-- Demander le vendeur au login
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('prison:server:RequestVendorSpawn')
end)

-- Événement de Premier Spawn & Tutoriel
RegisterNetEvent('prison:client:FirstSpawn')
AddEventHandler('prison:client:FirstSpawn', function()
    -- On attend que le joueur soit bien sur la map
    Citizen.Wait(2000)

    -- Création du personnage (ESX Skin)
    TriggerEvent('esx_skin:openSaveableMenu')

    -- Spawn dans la prison
    SetEntityCoords(PlayerPedId(), Config.TutorialPath.SpawnCoord.x, Config.TutorialPath.SpawnCoord.y, Config.TutorialPath.SpawnCoord.z)
    TriggerEvent('esx:showNotification', '~b~Tutoriel de la Prison~s~\nSuivez le guide pour comprendre votre nouvelle vie.')

    -- Apparition du Guide Tutoriel
    RequestModel(Config.TutorialPath.Model)
    while not HasModelLoaded(Config.TutorialPath.Model) do Citizen.Wait(10) end
    local guidePed = CreatePed(4, GetHashKey(Config.TutorialPath.Model), Config.TutorialPath.SpawnCoord.x + 2.0, Config.TutorialPath.SpawnCoord.y, Config.TutorialPath.SpawnCoord.z, 0.0, false, true)
    SetEntityInvincible(guidePed, true)

    Citizen.CreateThread(function()
        for i=1, #Config.TutorialPath.Nodes do
            local node = Config.TutorialPath.Nodes[i]
            TaskGoStraightToCoord(guidePed, node.coords.x, node.coords.y, node.coords.z, 1.0, -1, 0.0, 0.0)

            -- Attendre que le PNJ arrive au node
            while #(GetEntityCoords(guidePed) - node.coords) > 2.0 do
                Citizen.Wait(500)
            end

            -- Attendre le joueur
            while #(GetEntityCoords(PlayerPedId()) - node.coords) > 5.0 do
                TriggerEvent('esx:showNotification', '~r~Le guide vous attend.')
                Citizen.Wait(2000)
            end

            TriggerEvent('chat:addMessage', { args = {"Guide", node.text} })
            Citizen.Wait(5000) -- Temps de lecture
        end

        TriggerEvent('esx:showNotification', 'Fin du tutoriel. Bienvenue en enfer.')
        DeleteEntity(guidePed)
    end)
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

        -- Quête Illégale
        if isJailed and not isWorking then
            local qdist = #(pedCoords - vector3(Config.QuestNPC.Coords.x, Config.QuestNPC.Coords.y, Config.QuestNPC.Coords.z))
            if qdist < 3.0 then
                sleep = false
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour parler')
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('chat:addMessage', { args = {"Détenu Louche", Config.QuestNPC.Text} })
                    TriggerServerEvent('prison:server:CompleteQuest')
                end
            end
        end

        -- Vendeur Illégal
        if isJailed and not isWorking and currentVendorCoords then
            local vdist = #(pedCoords - vector3(currentVendorCoords.x, currentVendorCoords.y, currentVendorCoords.z))
            if vdist < 3.0 then
                sleep = false
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour voir la marchandise')
                if IsControlJustReleased(0, 38) then
                    -- Exemple simple: Acheter le premier item (peut être converti en menu esx_menu_default)
                    TriggerEvent('chat:addMessage', { args = {"Vendeur", "Achat: " .. Config.BlackMarket.Items[1].label .. " pour " .. Config.BlackMarket.Items[1].price .. "$ (Tape /acheter_illegal 1)"} })
                end
            end
        end

        -- Interaction Gardes Statiques
        for i=1, #spawnedNPCs do
            local npcData = spawnedNPCs[i]
            local gdist = #(pedCoords - GetEntityCoords(npcData.ped))
            if gdist < 3.0 then
                sleep = false
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour parler au garde')
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('chat:addMessage', { args = {"Garde", npcData.text} })
                end
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

-- Commande d'achat illégal temporaire
RegisterCommand('acheter_illegal', function(source, args)
    if isJailed then
        local index = tonumber(args[1])
        if index then TriggerServerEvent('prison:server:BuyBlackMarket', index) end
    end
end, false)
