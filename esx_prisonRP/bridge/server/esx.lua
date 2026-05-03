if GetFramework() ~= "esx" then return end

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function AddPlayerMoney(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addAccountMoney(Config.Currency, amount)
    end
end

function GetPlayerIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.identifier
    end
    return nil
end

function GetPlayerJob(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.job.name
    end
    return nil
end

function ReducePlayerJailTime(source, identifier, reduction)
    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] and result[1].jail_time then
            local currentJailTime = tonumber(result[1].jail_time)
            if currentJailTime > 0 then
                local newJailTime = currentJailTime - reduction
                if newJailTime < 0 then newJailTime = 0 end

                MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
                    ['@jail_time'] = newJailTime,
                    ['@identifier'] = identifier
                }, function(rowsChanged)
                    if newJailTime <= 0 then
                        TriggerClientEvent('chat:addMessage', source, { args = { '^2[Prison]', 'Votre peine est terminée.' } })
                        TriggerClientEvent('prison:client:release', source)
                    else
                        TriggerClientEvent('chat:addMessage', source, { args = { '^2[Prison]', 'Peine réduite. Temps restant: ' .. newJailTime .. ' minutes.' } })
                    end
                end)
            end
        end
    end)
end

function SyncCharacterJailStatus(identifier)
    local baseIdentifier = string.gsub(identifier, "_%d+$", "")

    MySQL.Async.fetchAll("SELECT identifier, jail_time FROM users WHERE identifier LIKE @search", {
        ["@search"] = baseIdentifier .. "%"
    }, function(results)
        local isJailed = false
        local highestJailTime = 0

        for _, row in ipairs(results) do
            if row.jail_time and tonumber(row.jail_time) > 0 then
                isJailed = true
                if tonumber(row.jail_time) > highestJailTime then
                    highestJailTime = tonumber(row.jail_time)
                end
            end
        end

        if isJailed then
            MySQL.Async.execute("UPDATE users SET jail_time = @time WHERE identifier = @id", {
                ["@time"] = highestJailTime,
                ["@id"] = identifier
            }, function(changed)
                -- Get player online and notify if necessary
            end)
        end
    end)
end
