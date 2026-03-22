ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
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
local createdBlips = {}

-- Initialisation des templates de Chat (Beau Chat)
-- Initialisation des templates de Chat (Beau Chat Réaliste)
Citizen.CreateThread(function()
    -- Haut-parleur / Interphone de la prison (Système)
    TriggerEvent('chat:addTemplate', 'prison_system', '<div style="padding: 0.6vw; margin: 0.5vw; background: linear-gradient(90deg, rgba(139,0,0,0.9) 0%, rgba(205,92,92,0.8) 100%); border-left: 5px solid darkred; border-radius: 4px; color: white; font-family: Courier New, monospace; text-transform: uppercase;"><i class="fas fa-volume-up"></i> [HAUT-PARLEUR] {0}<br><span style="font-size: 0.9em; opacity: 0.9;">{1}</span></div>')

    -- Radio / Talkie-Walkie des Gardes
    TriggerEvent('chat:addTemplate', 'prison_radio', '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(47,79,79,0.9); border-left: 5px solid lightblue; border-radius: 4px; color: white; font-family: Tahoma, sans-serif;"><i class="fas fa-broadcast-tower"></i> [RADIO PÉNITENTIAIRE] {0}: {1}</div>')

    -- Discussion PNJ / Guide
    TriggerEvent('chat:addTemplate', 'prison_guide', '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255,215,0,0.2); border-bottom: 2px solid gold; border-radius: 4px; color: white; font-style: italic;"><i class="fas fa-user-circle"></i> {0} murmure : "{1}"</div>')

    TriggerEvent('chat:addTemplate', 'prison_npc', '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0,0,0,0.6); border: 1px solid gray; border-radius: 4px; color: lightgray;"><i class="fas fa-mask"></i> {0} : {1}</div>')
end)

local isLockdown = false
RegisterNetEvent('prison:client:SetLockdown')
AddEventHandler('prison:client:SetLockdown', function(state)
    isLockdown = state
    if isLockdown then
        TriggerEvent('chat:addMessage', { templateId = 'prison_system', args = {"SÉCURITÉ MAXIMUM", "LOCKDOWN INITIÉ. TOUS LES DÉTENUS DOIVENT RETOURNER DANS LEURS CELLULES IMMÉDIATEMENT."} })
        PlaySoundFrontend(-1, "ALARM_TEXT", "DLC_PROLOGUE_ALARM_SOUNDS", true)
        SetTimecycleModifier('NG_filmic02')
    else
        TriggerEvent('chat:addMessage', { templateId = 'prison_system', args = {"SÉCURITÉ", "FIN DU LOCKDOWN. RETOUR À LA NORMALE."} })
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
    if isJailed or pedJob == Config.Jobs.Garde or pedJob == Config.Jobs.Police then

        -- Armurerie (Uniquement forces de l'ordre)
        if pedJob == Config.Jobs.Garde or pedJob == Config.Jobs.Police then
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
local receptionPed = nil

-- Fonction pour démarrer le tutoriel après avoir choisi "Prisonnier"
function StartPrisonerTutorial(ped)
    SetEntityCoords(ped, Config.ReceptionGuard.Coords.x, Config.ReceptionGuard.Coords.y, Config.ReceptionGuard.Coords.z)
    TriggerEvent('esx:showNotification', '~b~Tutoriel de la Prison~s~\nSuivez le guide pour comprendre votre nouvelle vie.')

    -- Apparition du Guide Tutoriel
    RequestModel(Config.TutorialPath.Model)
    while not HasModelLoaded(Config.TutorialPath.Model) do Citizen.Wait(10) end
    local guidePed = CreatePed(4, GetHashKey(Config.TutorialPath.Model), Config.ReceptionGuard.Coords.x + 2.0, Config.ReceptionGuard.Coords.y, Config.ReceptionGuard.Coords.z, 0.0, false, true)
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

            TriggerEvent('chat:addMessage', { templateId = 'prison_guide', args = {"Guide", node.text} })
            Citizen.Wait(5000) -- Temps de lecture
        end

        TriggerEvent('esx:showNotification', 'Fin du tutoriel. Bienvenue en enfer.')
        DeleteEntity(guidePed)
    end)
end

-- Fonction pour le choix de rôle
function OpenRoleChoiceMenu(ped)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'initial_job_choice', {
        title    = 'Choix de votre destin',
        align    = 'center',
        elements = {
            {label = 'Devenir Garde Pénitentiaire', value = 'garde'},
            {label = 'Devenir Prisonnier (20 mois)', value = 'prisonnier'}
        }
    }, function(data, menu)
        menu.close()
        local choice = data.current.value

        waitingForRoleChoice = false
        if receptionPed and DoesEntityExist(receptionPed) then DeleteEntity(receptionPed) end

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
end

-- Événement de Premier Spawn & Tutoriel (Cinématique LSPD)
RegisterNetEvent('prison:client:FirstSpawn')
AddEventHandler('prison:client:FirstSpawn', function()
    Citizen.Wait(2000)
    local ped = PlayerPedId()

    -- Début de la cinématique
    DoScreenFadeOut(1000)
    Citizen.Wait(1500)

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
    SetEntityCoords(ped, Config.ReceptionGuard.Coords.x, Config.ReceptionGuard.Coords.y, Config.ReceptionGuard.Coords.z)
    Citizen.Wait(2000)
    DeleteVehicle(policeCar)
    DeleteEntity(copPed)

    -- Spawn du Garde d'Accueil
    RequestModel(Config.ReceptionGuard.Model)
    while not HasModelLoaded(Config.ReceptionGuard.Model) do Citizen.Wait(10) end
    receptionPed = CreatePed(4, GetHashKey(Config.ReceptionGuard.Model), Config.ReceptionGuard.Coords.x, Config.ReceptionGuard.Coords.y, Config.ReceptionGuard.Coords.z - 1.0, Config.ReceptionGuard.Coords.w, false, true)
    SetEntityInvincible(receptionPed, true)
    SetBlockingOfNonTemporaryEvents(receptionPed, true)

    -- Création du personnage (ESX Skin) APRÈS la cinématique
    TriggerEvent('esx:showNotification', '~b~Créez votre personnage.~s~')

    -- On ouvre le menu, on laisse le joueur le configurer.
    -- esx_skin ferme le menu de lui-même à la fin. On n'attend pas de callback ici pour éviter les bugs.
    TriggerEvent('esx_skin:openSaveableMenu')

    -- On informe le joueur d'aller voir le garde une fois fini
    TriggerEvent('chat:addMessage', { templateId = 'prison_npc', args = {"Garde d'Accueil", Config.ReceptionGuard.Text} })
    waitingForRoleChoice = true
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

            -- Fouille d'un joueur proche (Gardes)
            if IsControlJustReleased(0, 47) then -- Touche G (Exemple)
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance < 2.0 then
                    TriggerServerEvent('prison:server:SearchPlayer', GetPlayerServerId(closestPlayer))
                else
                    TriggerEvent('esx:showNotification', '~r~Personne à proximité.')
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

        -- Interaction Garde d'Accueil (Tutoriel)
        if waitingForRoleChoice and receptionPed then
            local rdist = #(pedCoords - GetEntityCoords(receptionPed))
            if rdist < 3.0 then
                sleep = false
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour choisir votre rôle')
                if IsControlJustReleased(0, 38) then
                    OpenRoleChoiceMenu(PlayerPedId())
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
