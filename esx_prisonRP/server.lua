ESX = exports["es_extended"]:getSharedObject()

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
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not Config.PrisonerJobs[jobName] then return end

    local rewardData = Config.PrisonerJobs[jobName].Reward
    local timeReduction = rewardData.timeReduction
    local message = rewardData.msg

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

            -- Exemples de paiements (facultatif)
            -- xPlayer.addAccountMoney('black_money', 10)
        end
    end)
end)

-- Vérification à la connexion (remettre en prison si déco/reco)
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] and result[1].jail_time > 0 then
            TriggerClientEvent('prison:client:JailPlayer', source, result[1].jail_time)
        end
    end)
end)
