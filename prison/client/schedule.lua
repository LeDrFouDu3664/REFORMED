local currentPhase = "Reveil"

RegisterNetEvent("prison:client:scheduleUpdate")
AddEventHandler("prison:client:scheduleUpdate", function(phase)
    currentPhase = phase
    -- Trigger UI update or notification
    -- ShowNotification("Nouvelle activité: " .. currentPhase)
    SendNUIMessage({
        action = "updateSchedule",
        phase = currentPhase
    })
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    TriggerServerEvent("prison:server:getSchedule")
end)
