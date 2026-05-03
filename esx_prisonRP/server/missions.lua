local activeMissions = {}

RegisterNetEvent("prison:server:requestMission")
AddEventHandler("prison:server:requestMission", function(giverId)
    local _source = source
    if not Config.Settings.EnableMissions then return end

    local missionData = nil
    for _, m in ipairs(Config.Missions) do
        if m.giver == giverId then
            missionData = m
            break
        end
    end

    if missionData then
        if activeMissions[_source] then
            -- Determine if they finished it
            -- In a real inventory script, we would check if they have the item.
            -- Since inventory is framework dependent, we simulate mission completion
            -- by allowing them to finish it if 60 seconds have passed.
            if (os.time() - activeMissions[_source].time) > 60 then
                activeMissions[_source] = nil
                AddPlayerMoney(_source, missionData.reward)
                TriggerClientEvent("chat:addMessage", _source, { args = { '^5[Chef d\'atelier]', 'Bon travail. Voici ta paie.' } })
            else
                TriggerClientEvent("chat:addMessage", _source, { args = { '^5[Chef d\'atelier]', 'Tu n\'as pas encore fini. Reviens plus tard.' } })
            end
        else
            activeMissions[_source] = { time = os.time(), type = giverId }
            TriggerClientEvent("chat:addMessage", _source, { args = { '^5[Chef d\'atelier]', missionData.dialogue } })
        end
    end
end)
