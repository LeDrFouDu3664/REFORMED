local isDoingActivity = false

local activities = {
    gym = {
        coords = vector3(1643.0, 2528.0, 45.0),
        animDict = "amb@world_human_muscle_free_weights@male@barbell@base",
        animName = "base",
        label = "faire de la musculation"
    },
    trash = {
        coords = vector3(1655.0, 2540.0, 45.0),
        animDict = "amb@prop_human_bum_bin@base",
        animName = "base",
        label = "fouiller la poubelle"
    }
}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if not isDoingActivity then
            for actName, data in pairs(activities) do
                local dist = #(pos - data.coords)
                if dist < 5.0 then
                    sleep = 0
                    DrawMarker(1, data.coords.x, data.coords.y, data.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)

                    if dist < 1.5 then
                        SetTextComponentFormat("STRING")
                        AddTextComponentString("Appuyez sur ~INPUT_CONTEXT~ pour " .. data.label)
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                        if IsControlJustReleased(0, 38) then -- E
                            StartActivity(actName, data)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function StartActivity(actName, data)
    isDoingActivity = true
    TriggerServerEvent("prison:server:startActivity", actName)

    RequestAnimDict(data.animDict)
    while not HasAnimDictLoaded(data.animDict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), data.animDict, data.animName, 8.0, -8.0, -1, 1, 0, false, false, false)

    SendNUIMessage({
        action = "startProgress",
        duration = 5000,
        label = "Activité en cours..."
    })

    Citizen.Wait(5000)

    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("prison:server:completeActivity", actName)
    isDoingActivity = false
end
