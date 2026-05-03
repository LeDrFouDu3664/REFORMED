local activeActivities = {}

RegisterNetEvent("prison:server:startActivity")
AddEventHandler("prison:server:startActivity", function(actName)
    local _source = source
    activeActivities[_source] = { name = actName, time = os.time() }
end)

RegisterNetEvent("prison:server:completeActivity")
AddEventHandler("prison:server:completeActivity", function(actName)
    local _source = source

    local activeAct = activeActivities[_source]
    if not activeAct or activeAct.name ~= actName or (os.time() - activeAct.time) < 4 then
        print(("[Prison] Tentative d'exploit activité détectée par l'ID %s."):format(_source))
        return
    end

    activeActivities[_source] = nil

    if actName == "gym" then
        TriggerClientEvent('chat:addMessage', _source, { args = { '^2[Prison]', 'Vous vous sentez plus en forme !' } })
    elseif actName == "trash" then
        local chance = math.random(1, 100)
        if chance <= 30 then
            -- Can give a small item here using bridge inventory
            TriggerClientEvent('chat:addMessage', _source, { args = { '^2[Prison]', 'Vous avez trouvé quelque chose d\'utile dans la poubelle.' } })
        else
            TriggerClientEvent('chat:addMessage', _source, { args = { '^2[Prison]', 'Rien d\'intéressant dans cette poubelle.' } })
        end
    end
end)
