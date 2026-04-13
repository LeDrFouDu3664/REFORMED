ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if ESX == nil then
    -- Fallback for newer ESX if TriggerEvent fails but export exists
    pcall(function() ESX = exports["es_extended"]:getSharedObject() end)
end

-- Configuration ox_inventory (si utilisé)
if Config.InventorySystem == 'ox_inventory' then
    exports.ox_inventory:RegisterStash('prison_stash', 'Effets Personnels (Prison)', 50, 100000, false)
end

local playerCooldowns = {}

-- Helper Function : Vérifier si un joueur est Staff (AdminSystem ou ID Discord)
function IsPlayerStaff(source)
    if source == 0 then return true end -- La console est toujours staff

    -- 1. Vérification via le système d'administration configuré
    if Config.AdminSystem == 'luxu_admin' then
        -- Vérification spécifique pour Luxu Admin
        if exports['luxu_admin']:IsAdmin(source) then
            return true
        end
    elseif Config.AdminSystem == 'esx' then
        -- Vérification standard ESX
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() ~= 'user' then
            return true
        end
    end

    -- 2. Vérification de l'ID Discord (Fallback universel / Standalone)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "^discord:") then
            local discordId = string.gsub(identifier, "discord:", "")
            for _, allowedId in ipairs(Config.StaffDiscordIDs) do
                if discordId == allowedId then
                    return true
                end
            end
        end
    end

    return false
end

-- Commande Lockdown
local isLockdownActive = false
RegisterCommand('prisonlockdown', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and (xPlayer.job.name == Config.Jobs.Garde or xPlayer.job.name == Config.Jobs.Police) then
        isLockdownActive = not isLockdownActive
        TriggerClientEvent('prison:client:SetLockdown', -1, isLockdownActive)

        -- Si ox_inventory, on pourrait aussi lock le stash.
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Seuls les gardes et la police peuvent initier un confinement.')
    end
end, false)

-- Soin Infirmerie
RegisterServerEvent('prison:server:UseInfirmaryBed')
AddEventHandler('prison:server:UseInfirmaryBed', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local healthCost = 50
    if xPlayer.getAccount('black_money').money >= healthCost or xPlayer.getMoney() >= healthCost then
        if xPlayer.getAccount('black_money').money >= healthCost then
            xPlayer.removeAccountMoney('black_money', healthCost)
        else
            xPlayer.removeMoney(healthCost)
        end
        TriggerClientEvent('prison:client:HealInBed', src)
    else
        TriggerClientEvent('esx:showNotification', src, "~r~Vous n'avez pas assez d'argent pour payer les soins (50$).")
    end
end)

-- Garde: Actions menottes et escorte
RegisterServerEvent('prison:server:ToggleCuff')
AddEventHandler('prison:server:ToggleCuff', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and (xPlayer.job.name == 'garde' or xPlayer.job.name == 'police') then
        TriggerClientEvent('prison:client:ToggleCuffStatus', targetId)
        TriggerClientEvent('esx:showNotification', src, "~g~Vous avez menotté/démenotté le joueur.")
    end
end)

RegisterServerEvent('prison:server:ToggleEscort')
AddEventHandler('prison:server:ToggleEscort', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and (xPlayer.job.name == 'garde' or xPlayer.job.name == 'police') then
        TriggerClientEvent('prison:client:ToggleEscortStatus', targetId, src)
    end
end)

-- Fouille de joueur (ox_inventory)
RegisterServerEvent('prison:server:SearchPlayer')
AddEventHandler('prison:server:SearchPlayer', function(targetId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if xPlayer and xTarget and xPlayer.job.name == Config.Jobs.Garde then
        local ped = GetPlayerPed(source)
        local targetPed = GetPlayerPed(targetId)
        if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) < 5.0 then
            if Config.InventorySystem == 'ox_inventory' then
                exports.ox_inventory:forceOpenInventory(source, 'player', targetId)
            else
                TriggerClientEvent('esx:showNotification', source, '~r~Système ESX par défaut non supporté pour cette fouille avancée. Utilisez ox_inventory.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, '~r~Joueur trop éloigné.')
        end
    end
end)

-- Commande Character Kill (CK) / Suppression de personnage
RegisterCommand('ck', function(source, args, rawCommand)
    -- Si la commande est lancée par la console (source == 0) ou un staff
    if source == 0 or IsPlayerStaff(source) then
        local targetId = tonumber(args[1])
        local reason = table.concat(args, " ", 2)

        if targetId then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                local identifier = xTarget.identifier
                if reason == "" then reason = "Mort RP" end
                local targetName = xTarget.getName() or GetPlayerName(targetId)

                DropPlayer(targetId, "Votre personnage a été supprimé (CK). Motif : " .. reason)

                -- Suppression complète des données avec léger délai pour éviter les conflits de sauvegarde de déconnexion ESX
                SetTimeout(3000, function()
                    MySQL.Async.execute('DELETE FROM users WHERE identifier = @identifier', { ['@identifier'] = identifier })
                    MySQL.Async.execute('DELETE FROM owned_vehicles WHERE owner = @identifier', { ['@identifier'] = identifier })
                    MySQL.Async.execute('DELETE FROM addon_account_data WHERE owner = @identifier', { ['@identifier'] = identifier })
                    MySQL.Async.execute('DELETE FROM addon_inventory_items WHERE owner = @identifier', { ['@identifier'] = identifier })
                    MySQL.Async.execute('DELETE FROM datastore_data WHERE owner = @identifier', { ['@identifier'] = identifier })
                end)

                if source ~= 0 then
                    TriggerClientEvent('esx:showNotification', source, '~g~Personnage CK avec succès pour l\'ID ' .. targetId .. '\nMotif : ' .. reason)
                else
                    print('Personnage CK avec succès pour l\'ID ' .. targetId .. ' Motif : ' .. reason)
                end
            else
                if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~r~Joueur introuvable.') else print('Joueur introuvable.') end
            end
        else
            if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~y~Usage: /ck [ID] [Motif]') else print('Usage: /ck [ID] [Motif]') end
        end
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas la permission.')
    end
end, false)

-- Commande Staff pour définir un job
-- Commande Staff pour définir un job en prison
RegisterCommand('setjobprison', function(source, args, rawCommand)
    if source == 0 or IsPlayerStaff(source) then
        local targetId = tonumber(args[1])
        local jobName = args[2]
        local grade = tonumber(args[3]) or 0

        if targetId and jobName then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                -- Check si le job existe de manière sécurisée ou force l'action via l'objet ESX
                xTarget.setJob(jobName, grade)

                -- Forcer l'écriture base de données directement pour garantir compatibilité tous plugins
                MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @grade WHERE identifier = @identifier', {
                    ['@job'] = jobName,
                    ['@grade'] = grade,
                    ['@identifier'] = xTarget.identifier
                })

                if jobName == 'prisonnier' then
                    MySQL.Async.execute('UPDATE users SET jail_time = 99999 WHERE identifier = @identifier', {
                        ['@identifier'] = xTarget.identifier
                    }, function()
                        -- Exécuter le teleport client
                        TriggerClientEvent('prison:client:JailPlayer', targetId, 99999, false)
                    end)
                    if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~g~Joueur emprisonné à vie (Job: ' .. jobName .. ').') else print('Joueur emprisonné.') end
                else
                    if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~g~Métier défini : ' .. jobName .. ' (' .. grade .. ').') else print('Métier défini') end
                end
            else
                if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~r~Joueur introuvable en ligne.') else print('Joueur introuvable.') end
            end
        else
            if source ~= 0 then TriggerClientEvent('esx:showNotification', source, '~y~Usage: /setjobprison [ID] [job] [grade]') else print('Usage: /setjobprison [ID] [job] [grade]') end
        end
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas la permission.')
    end
end, false)

-- Commande pour mettre en prison
RegisterCommand('jail', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == Config.Jobs.Police or xPlayer.job.name == Config.Jobs.Garde then
        local targetId = tonumber(args[1])
        local jailTime = tonumber(args[2]) or 99999 -- Prison fédérale permanente par défaut si aucun temps n'est défini

        if targetId then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
                    ['@jail_time'] = jailTime,
                    ['@identifier'] = xTarget.identifier
                })
                TriggerClientEvent('prison:client:JailPlayer', targetId, jailTime)
                if jailTime >= 99999 then
                    TriggerClientEvent('esx:showNotification', source, 'Vous avez emprisonné ' .. xTarget.getName() .. ' à perpétuité.')
                else
                    TriggerClientEvent('esx:showNotification', source, 'Vous avez emprisonné ' .. xTarget.getName() .. ' pour ' .. jailTime .. ' mois.')
                end
            else
                TriggerClientEvent('esx:showNotification', source, 'Joueur introuvable.')
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'Usage: /jail [ID] [TEMPS (en mois)]')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas la permission de faire cela.')
    end
end, false)

-- Commande pour libérer
RegisterCommand('unjail', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == Config.Jobs.Police or xPlayer.job.name == Config.Jobs.Garde then
        local targetId = tonumber(args[1])
        if targetId then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
                    ['@identifier'] = xTarget.identifier
                })
                TriggerClientEvent('prison:client:UnjailPlayer', targetId)
                TriggerClientEvent('esx:showNotification', source, 'Vous avez libéré ' .. xTarget.getName())
            end
        end
    end
end, false)

-- Armement pour les gardes
RegisterServerEvent('prison:server:GiveGuardWeapons')
AddEventHandler('prison:server:GiveGuardWeapons', function(gearType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job.name == 'garde' then
        if gearType == 'standard' then
            xPlayer.addWeapon('WEAPON_STUNGUN', 100)
            xPlayer.addWeapon('WEAPON_NIGHTSTICK', 1)
            xPlayer.addWeapon('WEAPON_FLASHLIGHT', 1)
        elseif gearType == 'riot' and xPlayer.job.grade >= 3 then
            xPlayer.addWeapon('WEAPON_STUNGUN', 100)
            xPlayer.addWeapon('WEAPON_NIGHTSTICK', 1)
            xPlayer.addWeapon('WEAPON_PUMPSHOTGUN', 100)
            xPlayer.addWeapon('WEAPON_SMG', 250)
            -- Ajouter un gilet par balles
            TriggerClientEvent('esx:showNotification', source, '~r~Équipement Anti-Émeute équipé.')
        end
    elseif xPlayer and xPlayer.job.name == 'garde_incendie' then
        if gearType == 'fire' then
            xPlayer.addWeapon('WEAPON_FIREEXTINGUISHER', 100)
            xPlayer.addWeapon('WEAPON_HATCHET', 1)
            TriggerClientEvent('esx:showNotification', source, '~b~Équipement Incendie équipé.')
        end
    end
end)

-- Reset jail time in DB upon natural completion
RegisterServerEvent('prison:server:FinishJail')
AddEventHandler('prison:server:FinishJail', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })
        TriggerClientEvent('prison:client:UnjailPlayer', source)
    end
end)

-- Reward pour les prisonniers
RegisterServerEvent('prison:server:RewardPrisoner')
AddEventHandler('prison:server:RewardPrisoner', function(jobName)
    local source = source

    -- Sécurité Anti-Spam (10 secondes)
    local currentTime = os.time()
    if playerCooldowns[source] and (currentTime - playerCooldowns[source]) < 10 then
        -- Cooldown non respecté, potentiellement un tricheur
        return
    end
    playerCooldowns[source] = currentTime

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not Config.PrisonerJobs[jobName] then return end

    local rewardData = Config.PrisonerJobs[jobName].Reward
    local timeReduction = rewardData.timeReduction
    local message = rewardData.msg
    local moneyReward = rewardData.money or 0

    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] and result[1].jail_time > 0 then
            local newTime = result[1].jail_time - timeReduction
            if newTime < 0 then newTime = 0 end

            MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
                ['@jail_time'] = newTime,
                ['@identifier'] = xPlayer.identifier
            })

            -- Informer le client de réduire son timer local
            TriggerClientEvent('prison:client:ReduceJailTime', source, timeReduction)
            TriggerClientEvent('esx:showNotification', source, message)

            -- Donner l'argent sale / propre
            if moneyReward > 0 then
                xPlayer.addAccountMoney('black_money', moneyReward)
            end

            -- Si c'est la fouille des poubelles
            if jobName == 'TrashSearch' then
                local roll = math.random(1, 100)
                local found = false
                for _, loot in ipairs(Config.TrashLoot) do
                    if roll <= loot.chance then
                        xPlayer.addInventoryItem(loot.item, 1)
                        TriggerClientEvent('esx:showNotification', source, "~g~Vous avez trouvé : " .. loot.item)
                        found = true
                        break -- Seulement un item par fouille
                    end
                end
                if not found then
                    TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez rien trouvé d'intéressant.")
                end
            end
        end
    end)
end)

-- Quête : Échange illégal
RegisterServerEvent('prison:server:CompleteQuest')
AddEventHandler('prison:server:CompleteQuest', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local playerPed = GetPlayerPed(src)
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - vector3(Config.QuestNPC.Coords.x, Config.QuestNPC.Coords.y, Config.QuestNPC.Coords.z))

        if dist > 5.0 then return end -- Sécurité anti-triche

        local item = xPlayer.getInventoryItem(Config.QuestNPC.Requirement)
        if item and item.count > 0 then
            xPlayer.removeInventoryItem(Config.QuestNPC.Requirement, 1)
            xPlayer.addInventoryItem(Config.QuestNPC.Reward, 1)
            TriggerClientEvent('esx:showNotification', src, "Bien joué. Tiens, prends ça.")
        else
            TriggerClientEvent('esx:showNotification', src, "Tu te fous de moi ? Reviens quand tu auras le matos.")
        end
    end
end)

-- Gestion du Vendor Spawn Quotidien
local dailyVendorSpawn = nil

-- Cantine : Récupérer son plateau repas
local canteenCooldowns = {}
RegisterServerEvent('prison:server:GetFood')
AddEventHandler('prison:server:GetFood', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local currentTime = os.time()
    if canteenCooldowns[src] and (currentTime - canteenCooldowns[src]) < 300 then
        TriggerClientEvent('esx:showNotification', src, "~r~Vous avez déjà mangé. Attendez un peu.")
        return
    end

    canteenCooldowns[src] = currentTime
    xPlayer.addInventoryItem(Config.CanteenItems.Food.item, Config.CanteenItems.Food.count)
    xPlayer.addInventoryItem(Config.CanteenItems.Drink.item, Config.CanteenItems.Drink.count)
    TriggerClientEvent('esx:showNotification', src, "~g~Vous avez reçu un plateau repas.")
end)

-- Évasion de la Prison
RegisterServerEvent('prison:server:AttemptEscape')
AddEventHandler('prison:server:AttemptEscape', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local requiredItem = xPlayer.getInventoryItem(Config.Escape.RequiredItem)
    if requiredItem and requiredItem.count > 0 then
        -- Si l'item existe, on lance le process côté client
        TriggerClientEvent('prison:client:StartEscape', src)
    else
        TriggerClientEvent('esx:showNotification', src, "~r~Il vous faut un outil pour forcer le passage (" .. Config.Escape.RequiredItem .. ").")
    end
end)

RegisterServerEvent('prison:server:CompleteEscape')
AddEventHandler('prison:server:CompleteEscape', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(playerCoords - Config.Escape.StartCoords)

    if dist > 5.0 then return end -- Sécurité anti-triche

    local requiredItem = xPlayer.getInventoryItem(Config.Escape.RequiredItem)
    if requiredItem and requiredItem.count > 0 then
        -- Supprimer l'item (ex: lockpick cassé) avec une chance ou systématiquement
        xPlayer.removeInventoryItem(Config.Escape.RequiredItem, 1)

        -- Mettre à jour la DB pour dire qu'il n'est plus en prison physiquement (mais il est en cavale)
        -- Si vous avez un script de "wanted", vous pouvez l'ajouter ici.
        MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })

        -- Alerter la police et les gardes (Compatible ESX v1 / Legacy)
        local allPlayers = ESX.GetPlayers()
        local alertMsg = Config.Escape.PoliceAlert

        for i=1, #allPlayers do
            local xPlayerId = allPlayers[i]
            local xTarget = ESX.GetPlayerFromId(xPlayerId)

            if xTarget and (xTarget.job.name == Config.Jobs.Police or xTarget.job.name == Config.Jobs.Garde) then
                TriggerClientEvent('chat:addMessage', xPlayerId, { templateId = 'prison_system', args = {"ALERTE", alertMsg} })
            end
        end

        -- Confirmer l'évasion au joueur
        TriggerClientEvent('prison:client:EscapeSuccess', src)
    end
end)

-- Achat Vendeur Illégal
RegisterServerEvent('prison:server:BuyBlackMarket')
AddEventHandler('prison:server:BuyBlackMarket', function(itemIndex)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and dailyVendorSpawn then
        local playerPed = GetPlayerPed(src)
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - vector3(dailyVendorSpawn.x, dailyVendorSpawn.y, dailyVendorSpawn.z))

        if dist > 5.0 then return end -- Sécurité anti-triche

        local itemData = Config.BlackMarket.Items[itemIndex]
        if itemData then
            local money = xPlayer.getAccount('black_money').money
            if money >= itemData.price then
                xPlayer.removeAccountMoney('black_money', itemData.price)
                xPlayer.addInventoryItem(itemData.item, 1)
                TriggerClientEvent('esx:showNotification', src, "Transaction réussie.")
            else
                TriggerClientEvent('esx:showNotification', src, "~r~Pas assez d'argent sale.")
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 60 * 60) -- Change toutes les heures (irl)
        local randomIndex = math.random(1, #Config.BlackMarket.Spawns)
        dailyVendorSpawn = Config.BlackMarket.Spawns[randomIndex]
        TriggerClientEvent('prison:client:UpdateVendorSpawn', -1, dailyVendorSpawn)
    end
end)

RegisterServerEvent('prison:server:RequestVendorSpawn')
AddEventHandler('prison:server:RequestVendorSpawn', function()
    if dailyVendorSpawn == nil then
        local randomIndex = math.random(1, #Config.BlackMarket.Spawns)
        dailyVendorSpawn = Config.BlackMarket.Spawns[randomIndex]
    end
    TriggerClientEvent('prison:client:UpdateVendorSpawn', source, dailyVendorSpawn)
end)

local firstSpawnPlayers = {}

-- Rôle initial (Garde ou Prisonnier)
RegisterServerEvent('prison:server:SetInitialRole')
AddEventHandler('prison:server:SetInitialRole', function(role)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    -- Sécurité Anti-Triche : le joueur ne peut appeler ça qu'une seule fois
    if not firstSpawnPlayers[source] then
        print("[PrisonRP] Le joueur " .. source .. " a tenté de bypass le choix du métier initial.")
        return
    end
    firstSpawnPlayers[source] = nil

    if role == 'garde' then
        xPlayer.setJob('garde', 0)
    elseif role == 'prisonnier' then
        -- Prison à vie par défaut
        MySQL.Async.execute('UPDATE users SET jail_time = 99999 WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('prison:client:JailPlayer', source, 99999, false)
            end
        end)
    end
end)

-- Vérification à la connexion (remettre en prison si déco/reco, et premier spawn)
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    MySQL.Async.fetchAll('SELECT jail_time, first_spawn FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            -- Gestion du jail_time existant
            if result[1].jail_time > 0 then
                TriggerClientEvent('prison:client:JailPlayer', source, result[1].jail_time, true)
            -- Gestion du tout premier spawn (uniquement s'ils ne sont pas déjà en prison)
            elseif result[1].first_spawn == 1 then
                MySQL.Async.execute('UPDATE users SET first_spawn = 0 WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        firstSpawnPlayers[source] = true
                        TriggerClientEvent('prison:client:FirstSpawn', source)
                    end
                end)
            end
        end
    end)
end)
