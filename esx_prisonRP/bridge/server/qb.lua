if GetFramework() ~= "qbcore" then return end

QBCore = exports['qb-core']:GetCoreObject()

function AddPlayerMoney(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local account = "cash"
        if Config.Currency == "bank" then account = "bank" end
        Player.Functions.AddMoney(account, amount, "prison-job-reward")
    end
end

function GetPlayerIdentifier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return nil
end

function GetPlayerJob(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.job.name
    end
    return nil
end

function ReducePlayerJailTime(source, identifier, reduction)
    local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    if Player then
        local currentJailTime = Player.PlayerData.metadata["injail"] or 0
        if currentJailTime > 0 then
            local newJailTime = currentJailTime - reduction
            if newJailTime <= 0 then
                newJailTime = 0
                TriggerClientEvent('chat:addMessage', source, { args = { '^2[Prison]', 'Votre peine est terminée.' } })
                TriggerClientEvent('prison:client:release', source)
            else
                TriggerClientEvent('chat:addMessage', source, { args = { '^2[Prison]', 'Peine réduite. Temps restant: ' .. newJailTime .. ' minutes.' } })
            end
            Player.Functions.SetMetaData("injail", newJailTime)
            -- QBCore usually handles saving metadata automatically, or you can force save:
            Player.Functions.Save()
        end
    end
end

function SyncCharacterJailStatus(identifier)
    -- In QBCore, characters are usually identified by citizenid and tied to a license
    -- This requires a custom lookup depending on how the multicharacter script ties them.
    -- Assuming a common scenario where multiple characters share the same license:
    local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    if not Player then return end

    local license = Player.PlayerData.license

    MySQL.Async.fetchAll("SELECT citizenid, metadata FROM players WHERE license = @license", {
        ["@license"] = license
    }, function(results)
        local isJailed = false
        local highestJailTime = 0

        for _, row in ipairs(results) do
            if row.metadata then
                local meta = json.decode(row.metadata)
                if meta and meta.injail and tonumber(meta.injail) > 0 then
                    isJailed = true
                    if tonumber(meta.injail) > highestJailTime then
                        highestJailTime = tonumber(meta.injail)
                    end
                end
            end
        end

        if isJailed then
            Player.Functions.SetMetaData("injail", highestJailTime)
            Player.Functions.Save()
            TriggerClientEvent('chat:addMessage', Player.PlayerData.source, { args = { '^1[Système]', 'Votre autre personnage est en prison. Vous purgez sa peine.' } })
        end
    end)
end
