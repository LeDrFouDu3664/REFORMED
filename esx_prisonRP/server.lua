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

-- Commande pour mettre en prison
RegisterCommand('jail', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.job.name == Config.Jobs.Police or xPlayer.job.name == Config.Jobs.Garde then
        local targetId = tonumber(args[1])
        local jailTime = tonumber(args[2])

        if targetId and jailTime then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
                    ['@jail_time'] = jailTime,
                    ['@identifier'] = xTarget.identifier
                })
                TriggerClientEvent('prison:client:JailPlayer', targetId, jailTime)
                TriggerClientEvent('esx:showNotification', source, 'Vous avez emprisonné ' .. xTarget.getName() .. ' pour ' .. jailTime .. ' mois.')
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
AddEventHandler('prison:server:GiveGuardWeapons', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == Config.Jobs.Garde then
        xPlayer.addWeapon('WEAPON_STUNGUN', 100)
        xPlayer.addWeapon('WEAPON_NIGHTSTICK', 1)
        xPlayer.addWeapon('WEAPON_FLASHLIGHT', 1)
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
        end
    end)
end)

-- Quête : Échange illégal
RegisterServerEvent('prison:server:CompleteQuest')
AddEventHandler('prison:server:CompleteQuest', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local item = xPlayer.getInventoryItem(Config.QuestNPC.Requirement)
        if item and item.count > 0 then
            xPlayer.removeInventoryItem(Config.QuestNPC.Requirement, 1)
            xPlayer.addInventoryItem(Config.QuestNPC.Reward, 1)
            TriggerClientEvent('esx:showNotification', source, "Bien joué. Tiens, prends ça.")
        else
            TriggerClientEvent('esx:showNotification', source, "Tu te fous de moi ? Reviens quand tu auras le matos.")
        end
    end
end)

-- Achat Vendeur Illégal
RegisterServerEvent('prison:server:BuyBlackMarket')
AddEventHandler('prison:server:BuyBlackMarket', function(itemIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local itemData = Config.BlackMarket.Items[itemIndex]
        if itemData then
            local money = xPlayer.getAccount('black_money').money
            if money >= itemData.price then
                xPlayer.removeAccountMoney('black_money', itemData.price)
                xPlayer.addInventoryItem(itemData.item, 1)
                TriggerClientEvent('esx:showNotification', source, "Transaction réussie.")
            else
                TriggerClientEvent('esx:showNotification', source, "~r~Pas assez d'argent sale.")
            end
        end
    end
end)

-- Gestion du Vendor Spawn Quotidien
local dailyVendorSpawn = nil

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
                })
                TriggerClientEvent('prison:client:FirstSpawn', source)
            end
        end
    end)
end)
