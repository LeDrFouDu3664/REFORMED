ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        if ESX == nil then
            pcall(function() ESX = exports["es_extended"]:getSharedObject() end)
        end
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    ESX.PlayerData = ESX.GetPlayerData()
    RefreshBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    RefreshBlips()
end)

local isJailed = false
local jailTime = 0
local isTutorialActive = false
local createdBlips = {}

-- Initialisation des templates de Chat (Beau Chat)
-- Initialisation des templates de Chat (Beau Chat Réaliste)
-- NUI Custom Chat Helper
RegisterNetEvent('prison:client:SendNUI')
AddEventHandler('prison:client:SendNUI', function(author, text, msgType)
    SendNUIMessage({
        action = 'showCustomChat',
        author = author,
        text = text,
        type = msgType -- 'system', 'radio', 'guide', 'npc'
    })
end)

local isLockdown = false
RegisterNetEvent('prison:client:SetLockdown')
AddEventHandler('prison:client:SetLockdown', function(state)
    isLockdown = state
    if isLockdown then
        TriggerEvent('prison:client:SendNUI', 'SÉCURITÉ MAXIMUM', "LOCKDOWN INITIÉ. TOUS LES DÉTENUS DOIVENT RETOURNER DANS LEURS CELLULES IMMÉDIATEMENT.", 'system')
        PlaySoundFrontend(-1, "ALARM_TEXT", "DLC_PROLOGUE_ALARM_SOUNDS", true)
        SetTimecycleModifier('NG_filmic02')
    else
        TriggerEvent('prison:client:SendNUI', 'SÉCURITÉ', "FIN DU LOCKDOWN. RETOUR À LA NORMALE.", 'system')
        ClearTimecycleModifier()
    end
end)

-- Gestion Dynamique des Blips
function RefreshBlips()
    -- Nettoyer les anciens blips
    for k, blip in pairs(createdBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    createdBlips = {}

    local pedJob = ESX.PlayerData.job and ESX.PlayerData.job.name or 'unemployed'

    -- Blip global de la Prison (Visible pour tout le monde, paramétré pour être bien visible sur la grande carte)
    local mainBlip = AddBlipForCoord(Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
    SetBlipSprite(mainBlip, 188)
    SetBlipDisplay(mainBlip, 4) -- 4 = Rendu sur la minimap ET la carte principale
    SetBlipScale(mainBlip, 1.5)
    SetBlipColour(mainBlip, 49) -- Rouge bien visible
    SetBlipAsShortRange(mainBlip, false) -- Visible de très loin
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Prison d'État")
    EndTextCommandSetBlipName(mainBlip)
    table.insert(createdBlips, mainBlip)

    -- Blips internes (seulement visibles par Gardes ou Prisonniers)
    if isJailed or pedJob == Config.GuardJob or pedJob == Config.PoliceJob or pedJob == Config.FireJob then

        -- Armurerie (Uniquement forces de l'ordre)
        if pedJob == Config.GuardJob or pedJob == Config.PoliceJob then
            local armoryBlip = AddBlipForCoord(Config.Locations.Armory.x, Config.Locations.Armory.y, Config.Locations.Armory.z)
            SetBlipSprite(armoryBlip, 175)
            SetBlipScale(armoryBlip, 0.8)
            SetBlipColour(armoryBlip, 38)
            SetBlipAsShortRange(armoryBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Armurerie Garde")
            EndTextCommandSetBlipName(armoryBlip)
            table.insert(createdBlips, armoryBlip)
        end

        -- Infirmerie EMS (Visible pour Prisonniers et Forces de l'ordre)
        local infBlip = AddBlipForCoord(Config.Locations.Infirmary.x, Config.Locations.Infirmary.y, Config.Locations.Infirmary.z)
        SetBlipSprite(infBlip, 153)
        SetBlipScale(infBlip, 0.8)
        SetBlipColour(infBlip, 1)
        SetBlipAsShortRange(infBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Infirmerie")
        EndTextCommandSetBlipName(infBlip)
        table.insert(createdBlips, infBlip)

        -- Blips des travaux et Stash (Uniquement Prisonniers)
        if isJailed then
            local stashBlip = AddBlipForCoord(Config.Locations.PrisonerStash.x, Config.Locations.PrisonerStash.y, Config.Locations.PrisonerStash.z)
            SetBlipSprite(stashBlip, 50)
            SetBlipScale(stashBlip, 0.8)
            SetBlipColour(stashBlip, 5)
            SetBlipAsShortRange(stashBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Effets Personnels")
            EndTextCommandSetBlipName(stashBlip)
            table.insert(createdBlips, stashBlip)

            local canteenBlip = AddBlipForCoord(Config.Locations.Canteen.x, Config.Locations.Canteen.y, Config.Locations.Canteen.z)
            SetBlipSprite(canteenBlip, 280)
            SetBlipScale(canteenBlip, 0.8)
            SetBlipColour(canteenBlip, 2)
            SetBlipAsShortRange(canteenBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Cantine")
            EndTextCommandSetBlipName(canteenBlip)
            table.insert(createdBlips, canteenBlip)

            local gymBlip = AddBlipForCoord(Config.Locations.Gym.x, Config.Locations.Gym.y, Config.Locations.Gym.z)
            SetBlipSprite(gymBlip, 311)
            SetBlipScale(gymBlip, 0.8)
            SetBlipColour(gymBlip, 5)
            SetBlipAsShortRange(gymBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Salle de Sport")
            EndTextCommandSetBlipName(gymBlip)
            table.insert(createdBlips, gymBlip)

            for jobName, jobData in pairs(Config.PrisonerJobs) do
                for _, coord in pairs(jobData.Coords) do
                    local jobBlip = AddBlipForCoord(coord.x, coord.y, coord.z)
                    SetBlipSprite(jobBlip, 566)
                    SetBlipScale(jobBlip, 0.8)
                    SetBlipColour(jobBlip, 5)
                    SetBlipAsShortRange(jobBlip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Travail : " .. jobName)
                    EndTextCommandSetBlipName(jobBlip)
                    table.insert(createdBlips, jobBlip)
                end
            end
        end
    end
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    RefreshBlips()
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
-- Création des groupes une seule fois au démarrage
AddRelationshipGroup("PRISONER")
AddRelationshipGroup("GUARD")
SetRelationshipBetweenGroups(1, GetHashKey("PRISONER"), GetHashKey("PLAYER"))
SetRelationshipBetweenGroups(1, GetHashKey("PLAYER"), GetHashKey("PRISONER"))
SetRelationshipBetweenGroups(1, GetHashKey("GUARD"), GetHashKey("PLAYER"))
SetRelationshipBetweenGroups(1, GetHashKey("PLAYER"), GetHashKey("GUARD"))

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- Empêcher le niveau de recherche
        if GetPlayerWantedLevel(PlayerId()) > 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
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
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedRelationshipGroupHash(ped, GetHashKey("GUARD"))
        table.insert(spawnedNPCs, {ped = ped, text = v.text})
    end

    -- PNJ de Quête
    RequestModel(Config.QuestNPC.Model)
    while not HasModelLoaded(Config.QuestNPC.Model) do Citizen.Wait(10) end
    local qped = CreatePed(4, GetHashKey(Config.QuestNPC.Model), Config.QuestNPC.Coords.x, Config.QuestNPC.Coords.y, Config.QuestNPC.Coords.z - 1.0, Config.QuestNPC.Coords.w, false, true)
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
local waitingForRoleChoice = false

-- Fonction pour démarrer le tutoriel après avoir choisi "Prisonnier"
function StartPrisonerTutorial(ped)
    isTutorialActive = true
    SetEntityCoords(ped, Config.TutorialPath.SpawnCoord.x, Config.TutorialPath.SpawnCoord.y, Config.TutorialPath.SpawnCoord.z)
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

            TriggerEvent('prison:client:SendNUI', "Guide", node.text, 'guide')
            Citizen.Wait(5000) -- Temps de lecture
        end

        TriggerEvent('esx:showNotification', 'Fin du tutoriel. Bienvenue en enfer.')
        DeleteEntity(guidePed)
        isTutorialActive = false
    end)
end

-- Événement de Premier Spawn & Tutoriel (Cinématique LSPD)
RegisterNetEvent('prison:client:FirstSpawn')
AddEventHandler('prison:client:FirstSpawn', function()
    Citizen.Wait(2000)
    local ped = PlayerPedId()

    -- Début de la cinématique
    DoScreenFadeOut(1000)
    Citizen.Wait(1500)

    -- Charger la map autour de la destination
    RequestCollisionAtCoord(Config.Cutscene.DropoffCar.x, Config.Cutscene.DropoffCar.y, Config.Cutscene.DropoffCar.z)
    SetFocusPosAndVel(Config.Cutscene.DropoffCar.x, Config.Cutscene.DropoffCar.y, Config.Cutscene.DropoffCar.z, 0.0, 0.0, 0.0)

    -- Spawn de la voiture de police
    RequestModel(Config.Cutscene.VehicleModel)
    while not HasModelLoaded(Config.Cutscene.VehicleModel) do Citizen.Wait(10) end
    local policeCar = CreateVehicle(GetHashKey(Config.Cutscene.VehicleModel), Config.Cutscene.SpawnCar.x, Config.Cutscene.SpawnCar.y, Config.Cutscene.SpawnCar.z, Config.Cutscene.SpawnCar.w, false, false)

    -- Spawn du policier (conducteur)
    RequestModel(Config.Cutscene.DriverModel)
    while not HasModelLoaded(Config.Cutscene.DriverModel) do Citizen.Wait(10) end
    local copPed = CreatePedInsideVehicle(policeCar, 4, GetHashKey(Config.Cutscene.DriverModel), -1, false, false)

    -- Placer le joueur dans la voiture (menotté)
    SetPedIntoVehicle(ped, policeCar, 1)

    DoScreenFadeIn(1000)
    TriggerEvent('esx:showNotification', '~r~LSPD :~s~ Allez, direction Bolingbroke pour un bon moment.')

    -- Conduire jusqu'au point de drop
    TaskVehicleDriveToCoordLongrange(copPed, policeCar, Config.Cutscene.DropoffCar.x, Config.Cutscene.DropoffCar.y, Config.Cutscene.DropoffCar.z, 15.0, 2883621, 5.0)

    local driveTimeout = 0
    while #(GetEntityCoords(policeCar) - vector3(Config.Cutscene.DropoffCar.x, Config.Cutscene.DropoffCar.y, Config.Cutscene.DropoffCar.z)) > 10.0 and driveTimeout < 30 do
        Citizen.Wait(1000)
        driveTimeout = driveTimeout + 1
    end

    -- Fin du trajet
    TaskLeaveVehicle(ped, policeCar, 0)
    Citizen.Wait(1000)
    SetEntityCoords(ped, Config.TutorialPath.SpawnCoord.x, Config.TutorialPath.SpawnCoord.y, Config.TutorialPath.SpawnCoord.z)
    Citizen.Wait(1000)
    DeleteVehicle(policeCar)
    DeleteEntity(copPed)
    ClearFocus()

    -- Création du personnage (ESX Skin) APRÈS la cinématique
    TriggerEvent('esx:showNotification', '~b~Créez votre personnage.~s~')

    -- On passe un callback pour lancer le tutoriel une fois la création de personnage confirmée.
    TriggerEvent('esx_skin:openSaveableMenu', function()
        -- Menu de Choix : Garde ou Prisonnier
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'initial_job_choice', {
            title    = 'Choix de votre destin',
            align    = 'center',
            elements = {
                {label = 'Devenir Garde Pénitentiaire', value = 'garde'},
                {label = 'Devenir Prisonnier (Fédéral)', value = 'prisonnier'}
            }
        }, function(data, menu)
            menu.close()
            local choice = data.current.value

            if choice == 'garde' then
                TriggerServerEvent('prison:server:SetInitialRole', 'garde')
                SetEntityCoords(ped, Config.Locations.Armory.x, Config.Locations.Armory.y, Config.Locations.Armory.z)
                TriggerEvent('esx:showNotification', '~g~Vous êtes maintenant Garde Pénitentiaire.~s~')
            elseif choice == 'prisonnier' then
                TriggerServerEvent('prison:server:SetInitialRole', 'prisonnier')
                StartPrisonerTutorial(ped)
            end
        end, function(data, menu)
            -- Empêche de fermer avec Échap
        end)
    end, function()
        -- Si annulation (échap), forcer prisonnier
        TriggerServerEvent('prison:server:SetInitialRole', 'prisonnier')
        StartPrisonerTutorial(ped)
    end)
end)

-- Événement d'emprisonnement
RegisterNetEvent('prison:client:JailPlayer')
AddEventHandler('prison:client:JailPlayer', function(time, isLogin)
    local wasAlreadyJailed = isJailed
    isJailed = true
    jailTime = time

    local ped = PlayerPedId()

    -- Téléportation en prison si ce n'est pas un login OU si on se connecte hors de la prison
    if not isLogin or #(GetEntityCoords(ped) - Config.PrisonCoords) > Config.PrisonRadius then
        SetEntityCoords(ped, Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
    end

    RemoveAllPedWeapons(ped, true)
    TriggerEvent('esx:showNotification', 'Vous purgez une peine de ' .. jailTime .. ' mois.')

    RefreshBlips()

    -- Boucle de prison (Peine Permanente / Fédérale)
    -- Le jailTime ne diminue plus naturellement. Le joueur doit être sorti par un garde ou s'évader.
    if not wasAlreadyJailed then
        Citizen.CreateThread(function()
            while isJailed do
                Citizen.Wait(1000)

                local pedCoords = GetEntityCoords(PlayerPedId())
                local dist = #(pedCoords - Config.PrisonCoords)

                -- Anti-évasion magique (suspendu pendant le tuto)
                if not isTutorialActive and dist > Config.PrisonRadius then
                    SetEntityCoords(PlayerPedId(), Config.PrisonCoords.x, Config.PrisonCoords.y, Config.PrisonCoords.z)
                    TriggerEvent('esx:showNotification', 'Le collier GPS vous ramène de force !')
                end

                -- Fin de peine manuelle (si le temps est manuellement forcé à 0)
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
    RefreshBlips()
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
            templateId = 'prison_system',
            multiline = true,
            args = {"Horaires de la Prison", msg}
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

-- Animation et process d'Évasion
RegisterNetEvent('prison:client:StartEscape')
AddEventHandler('prison:client:StartEscape', function()
    if isWorking then return end
    isWorking = true

    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)
    TriggerEvent('esx:showNotification', '~y~Vous tentez de forcer le passage...')

    -- Attendre la durée configurée
    Citizen.Wait(Config.Escape.Duration)

    ClearPedTasksImmediately(ped)
    isWorking = false
    TriggerServerEvent('prison:server:CompleteEscape')
end)

RegisterNetEvent('prison:client:EscapeSuccess')
AddEventHandler('prison:client:EscapeSuccess', function()
    isJailed = false
    jailTime = 0
    SetEntityCoords(PlayerPedId(), Config.Escape.ExitCoords.x, Config.Escape.ExitCoords.y, Config.Escape.ExitCoords.z)
    TriggerEvent('esx:showNotification', '~r~Vous vous êtes échappé ! Courez !')
    RefreshBlips()
end)

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

        -- Interaction Garde : Armureries
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.GuardJob then
            -- Équipement Standard
            local dist = #(pedCoords - Config.Locations.Armory)
            if dist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Armory.x, Config.Locations.Armory.y, Config.Locations.Armory.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 150, 255, 100, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour l\'équipement standard')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('prison:server:GiveGuardWeapons', 'standard')
                    end
                end
            end

            -- Équipement Anti-Émeute (Si grade >= 3)
            if ESX.PlayerData.job.grade >= 3 then
                local rDist = #(pedCoords - Config.Locations.RiotGear)
                if rDist < 10.0 then
                    sleep = false
                    DrawMarker(20, Config.Locations.RiotGear.x, Config.Locations.RiotGear.y, Config.Locations.RiotGear.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                    if rDist < 1.5 then
                        ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour l\'équipement Anti-Émeute')
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('prison:server:GiveGuardWeapons', 'riot')
                        end
                    end
                end
            end

            -- Fouille d'un joueur proche (Gardes)
            if IsControlJustReleased(0, 47) then -- Touche G (Exemple)
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance < 2.0 then
                    TriggerServerEvent('prison:server:SearchPlayer', GetPlayerServerId(closestPlayer))
                else
                    TriggerEvent('esx:showNotification', '~r~Personne à proximité.')
                end
            end
        elseif ESX.PlayerData.job and ESX.PlayerData.job.name == Config.FireJob then
            -- Équipement Incendie
            local fDist = #(pedCoords - Config.Locations.FireGear)
            if fDist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.FireGear.x, Config.Locations.FireGear.y, Config.Locations.FireGear.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 100, 0, 100, false, true, 2, false, nil, nil, false)
                if fDist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour l\'équipement Incendie')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('prison:server:GiveGuardWeapons', 'fire')
                    end
                end
            end
        end

        -- Interaction EMS : Infirmerie (Service & Lits)
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.EMSJob then
            local dist = #(pedCoords - Config.Locations.Infirmary)
            if dist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Infirmary.x, Config.Locations.Infirmary.y, Config.Locations.Infirmary.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour prendre votre service médical')
                    if IsControlJustReleased(0, 38) then -- Touche E
                        TriggerEvent('esx:showNotification', 'Vous êtes maintenant en position pour soigner les détenus.')
                    end
                end
            end
        end

        -- Lits Infirmerie (Se soigner)
        for _, bedCoords in ipairs(Config.InfirmaryBeds) do
            local bDist = #(pedCoords - bedCoords)
            if bDist < 3.0 then
                sleep = false
                DrawMarker(20, bedCoords.x, bedCoords.y, bedCoords.z - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                if bDist < 1.5 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour vous coucher/soigner")
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('prison:server:UseInfirmaryBed')
                    end
                end
            end
        end

        -- Fouille des poubelles (Prisonniers)
        if isJailed and not isWorking then
            for _, trashCoords in ipairs(Config.TrashSearchSpots) do
                local tDist = #(pedCoords - trashCoords)
                if tDist < 3.0 then
                    sleep = false
                    DrawMarker(1, trashCoords.x, trashCoords.y, trashCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 150, 75, 0, 100, false, false, 2, false, nil, nil, false)
                    if tDist < 1.5 then
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour fouiller")
                        if IsControlJustReleased(0, 38) then
                            StartPrisonWork('TrashSearch') -- Lancement du processus
                        end
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

            -- Cantine
            local canteenDist = #(pedCoords - Config.Locations.Canteen)
            if canteenDist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Canteen.x, Config.Locations.Canteen.y, Config.Locations.Canteen.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, nil, nil, false)
                if canteenDist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récupérer un plateau repas')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('prison:server:GetFood')
                    end
                end
            end

            -- Gym (Musculation Libre)
            local gymDist = #(pedCoords - Config.Locations.Gym)
            if gymDist < 10.0 then
                sleep = false
                DrawMarker(20, Config.Locations.Gym.x, Config.Locations.Gym.y, Config.Locations.Gym.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 100, 100, 255, 100, false, true, 2, false, nil, nil, false)
                if gymDist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour vous muscler')
                    if IsControlJustReleased(0, 38) then
                        StartPrisonWork('Workout') -- Utilise l'anim de gym définie dans le job
                    end
                end
            end

            -- Point d'Évasion
            local escDist = #(pedCoords - Config.Escape.StartCoords)
            if escDist < 10.0 then
                sleep = false
                DrawMarker(1, Config.Escape.StartCoords.x, Config.Escape.StartCoords.y, Config.Escape.StartCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
                if escDist < 1.5 then
                    ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour forcer la sortie')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('prison:server:AttemptEscape')
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
                    TriggerEvent('chat:addMessage', { templateId = 'prison_npc', args = {"Détenu Louche", Config.QuestNPC.Text} })
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
                    TriggerEvent('chat:addMessage', { templateId = 'prison_npc', args = {"Vendeur", "Achat: " .. Config.BlackMarket.Items[1].label .. " pour " .. Config.BlackMarket.Items[1].price .. "$ (Tape /acheter_illegal 1)"} })
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
                    TriggerEvent('chat:addMessage', { templateId = 'prison_npc', args = {"Garde", npcData.text} })
                end
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

-- Commandes d'animation de force (Gardes)
RegisterCommand('cuff', function()
    local ped = PlayerPedId()
    if ESX.PlayerData.job and (ESX.PlayerData.job.name == Config.GuardJob or ESX.PlayerData.job.name == Config.PoliceJob) then
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            TriggerServerEvent('prison:server:ToggleCuff', GetPlayerServerId(closestPlayer))
        else
            TriggerEvent('esx:showNotification', '~r~Aucun joueur à proximité.')
        end
    end
end, false)

RegisterCommand('escort', function()
    local ped = PlayerPedId()
    if ESX.PlayerData.job and (ESX.PlayerData.job.name == Config.GuardJob or ESX.PlayerData.job.name == Config.PoliceJob) then
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            TriggerServerEvent('prison:server:ToggleEscort', GetPlayerServerId(closestPlayer))
        else
            TriggerEvent('esx:showNotification', '~r~Aucun joueur à proximité.')
        end
    end
end, false)

-- Events Cuff & Escort Handler Client
local isCuffed = false
RegisterNetEvent('prison:client:ToggleCuffStatus')
AddEventHandler('prison:client:ToggleCuffStatus', function()
    isCuffed = not isCuffed
    local ped = PlayerPedId()
    if isCuffed then
        RequestAnimDict('mp_arresting')
        while not HasAnimDictLoaded('mp_arresting') do Citizen.Wait(10) end
        TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        SetEnableHandcuffs(ped, true)
        DisablePlayerFiring(ped, true)
        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
        SetPedCanPlayGestureAnims(ped, false)
    else
        ClearPedSecondaryTask(ped)
        SetEnableHandcuffs(ped, false)
        DisablePlayerFiring(ped, false)
        SetPedCanPlayGestureAnims(ped, true)
    end
end)

local isEscorted = false
local escortingPed = nil
RegisterNetEvent('prison:client:ToggleEscortStatus')
AddEventHandler('prison:client:ToggleEscortStatus', function(copId)
    isEscorted = not isEscorted
    local ped = PlayerPedId()
    escortingPed = copId

    if isEscorted then
        local targetPed = GetPlayerPed(GetPlayerFromServerId(copId))
        AttachEntityToEntity(ped, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    else
        DetachEntity(ped, true, false)
    end
end)

-- Soin via lit
RegisterNetEvent('prison:client:HealInBed')
AddEventHandler('prison:client:HealInBed', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    TriggerEvent('esx:showNotification', '~g~Vous avez été soigné.')
end)

-- Variables dynamiques HUD
local currentHunger = 100
local currentThirst = 100
local seatbelt = false
local cruiseControl = false
local cruiseSpeed = 0

-- Écoute des statuts pour la faim et soif (Si plugin esx_status présent)
AddEventHandler('esx_status:onTick', function(status)
    for k, v in ipairs(status) do
        if v.name == 'hunger' then currentHunger = math.floor(v.percent) end
        if v.name == 'thirst' then currentThirst = math.floor(v.percent) end
    end
end)

-- Thread NUI HUD Global (Affichage HUD)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200) -- Refresh plus rapide pour la vitesse du véhicule

        -- Si ESX est bien chargé
        if ESX and ESX.PlayerData then
            local ped = PlayerPedId()

            -- Calculs Santé/Armure
            -- Santé sur GTA V : 100 à 200 (Souvent, 100 = Mort) -> Formule (Santé - 100)
            local health = GetEntityHealth(ped) - 100
            if health < 0 then health = 0 end
            if health > 100 then health = 100 end

            local armor = GetPedArmour(ped)

            -- Heure/Date
            local year, month, day, hour, minute, second = GetLocalTime()
            local timeStr = string.format("%02d:%02d", hour, minute)
            local dateStr = string.format("%02d/%02d/%04d", day, month, year)

            -- ID Joueur
            local playerId = GetPlayerServerId(PlayerId())

            -- Récupération Locale (Pas de callback spam)
            local pData = ESX.GetPlayerData()
            local money, bank, black = 0, 0, 0

            if pData.accounts then
                for i=1, #pData.accounts do
                    local acc = pData.accounts[i]
                    if acc.name == 'money' then money = acc.money
                    elseif acc.name == 'bank' then bank = acc.money
                    elseif acc.name == 'black_money' then black = acc.money end
                end
            end

            -- Données Véhicule
            local inVehicle = false
            local speed = 0
            local gear = 0
            local fuel = 0
            local indicatorL = false
            local indicatorR = false

            if IsPedInAnyVehicle(ped, false) then
                inVehicle = true
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle and vehicle ~= 0 then
                    speed = math.floor(GetEntitySpeed(vehicle) * 3.6) -- Conversion m/s en km/h
                    gear = GetVehicleCurrentGear(vehicle)

                    -- Essence (Legacy ESX Fuel, Ox_Fuel ou LegacyFuel natif)
                    fuel = math.floor(GetVehicleFuelLevel(vehicle))

                    -- Clignotants (0 = Eteint, 1 = Gauche, 2 = Droite, 3 = Warning)
                    local lights = GetVehicleIndicatorLights(vehicle)
                    if lights == 1 then indicatorL = true
                    elseif lights == 2 then indicatorR = true
                    elseif lights == 3 then indicatorL = true; indicatorR = true end

                    -- Régulateur de Vitesse (Cruiser)
                    if cruiseControl and GetPedInVehicleSeat(vehicle, -1) == ped then
                        SetEntityMaxSpeed(vehicle, cruiseSpeed)
                    end
                end
            else
                -- Reset variables si on quitte le véhicule
                seatbelt = false
                cruiseControl = false
            end

            SendNUIMessage({
                action = 'updateHUD',
                id = playerId,
                time = timeStr,
                date = dateStr,
                money = money,
                bank = bank,
                black = black,
                health = health,
                armor = armor,
                hunger = currentHunger,
                thirst = currentThirst,
                inVehicle = inVehicle,
                speed = speed,
                gear = gear,
                fuel = fuel,
                seatbelt = seatbelt,
                cruiseControl = cruiseControl,
                indicatorL = indicatorL,
                indicatorR = indicatorR
            })
        end
    end
end)

-- Commandes / Touches Véhicule (Ceinture, Régulateur)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                -- Ceinture (Touche X - 73)
                if IsControlJustReleased(0, 73) then
                    seatbelt = not seatbelt
                    if seatbelt then
                        TriggerEvent('esx:showNotification', '~g~Ceinture attachée')
                    else
                        TriggerEvent('esx:showNotification', '~r~Ceinture détachée')
                    end
                end

                -- Régulateur (Touche G - 47)
                if IsControlJustReleased(0, 47) then
                    if cruiseControl then
                        cruiseControl = false
                        SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
                        TriggerEvent('esx:showNotification', '~r~Régulateur désactivé')
                    else
                        cruiseSpeed = GetEntitySpeed(vehicle)
                        if cruiseSpeed > 5.0 then
                            cruiseControl = true
                            TriggerEvent('esx:showNotification', '~g~Régulateur activé à ' .. math.floor(cruiseSpeed * 3.6) .. ' km/h')
                        else
                            TriggerEvent('esx:showNotification', '~y~Vitesse trop faible pour le régulateur')
                        end
                    end
                end

                -- Physique Ceinture (Empêcher l'éjection si attachée)
                if seatbelt then
                    DisableControlAction(0, 75, true) -- F (Sortir)
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

-- Écouteur pour la mise à jour asynchrone des comptes (optionnel pour la fluidité)
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    for i=1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i].money = account.money
            break
        end
    end
end)

-- Commande /hud (Déplacement de l'interface)
local hudEditMode = false
RegisterCommand('hud', function()
    hudEditMode = not hudEditMode
    SetNuiFocus(hudEditMode, hudEditMode)
    SendNUIMessage({
        action = 'toggleDragMode',
        state = hudEditMode
    })

    if hudEditMode then
        TriggerEvent('esx:showNotification', '~y~Mode Édition HUD Activé.~s~ Déplacez l\'interface et retapez /hud pour valider.')
    else
        TriggerEvent('esx:showNotification', '~g~Position HUD Sauvegardée.')
    end
end, false)

-- RegisterKeyMapping NUI Callback (Close HUD Edit with ESC)
RegisterNUICallback('closeEdit', function(data, cb)
    hudEditMode = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'toggleDragMode', state = false })
    cb('ok')
end)

-- Masquer le HUD natif de GTA (Sauf minimap et menu pause)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Masquer les composants spécifiques du HUD
        HideHudComponentThisFrame(1)  -- Wanted Stars
        HideHudComponentThisFrame(2)  -- Weapon Icon
        HideHudComponentThisFrame(3)  -- Cash
        HideHudComponentThisFrame(4)  -- MP Cash
        HideHudComponentThisFrame(6)  -- Vehicle Name
        HideHudComponentThisFrame(7)  -- Area Name
        HideHudComponentThisFrame(8)  -- Vehicle Class
        HideHudComponentThisFrame(9)  -- Street Name
        HideHudComponentThisFrame(13) -- Cash Change
        HideHudComponentThisFrame(14) -- Reticle
        HideHudComponentThisFrame(17) -- Save Game
        HideHudComponentThisFrame(20) -- Weapon Stats

        -- Disparition conditionnelle de la minimap
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
    end
end)

-- Auto-heal passif permanent en prison (compatible tout perso/plugin)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Toutes les 5 secondes
        if isJailed then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            -- Sur FiveM, la santé max de base d'un ped masculin est 200 (100-200)
            if health > 100 and health < 200 then
                SetEntityHealth(ped, health + 2)
            end
        else
            Citizen.Wait(5000)
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
