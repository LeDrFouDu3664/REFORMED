local isWorking = false

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- Check if player is a prisoner
        local job = GetPlayerJob()
        local isPrisoner = false
        for _, pJob in ipairs(Config.PrisonerJobs) do
            if job == pJob then
                isPrisoner = true
                break
            end
        end

        if isPrisoner and not isWorking then
            for jobName, coords in pairs(Config.Locations.Jobs) do
                local dist = #(pos - coords)
                if dist < 5.0 then
                    sleep = 0
                    DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)

                    if dist < 1.5 then
                        -- DisplayHelpText("Appuyez sur ~INPUT_CONTEXT~ pour travailler: " .. jobName)
                        -- ESX / QBCore help text abstraction if needed.
                        SetTextComponentFormat("STRING")
                        AddTextComponentString("Appuyez sur ~INPUT_CONTEXT~ pour travailler: " .. jobName)
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                        if IsControlJustReleased(0, 38) then -- E
                            StartJob(jobName)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function StartJob(jobName)
    isWorking = true
    TriggerServerEvent("prison:server:startJob", jobName)

    -- Play animation
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, true)

    -- ProgressBar / NUI
    SendNUIMessage({
        action = "startProgress",
        duration = 10000,
        label = "Travail en cours..."
    })

    Citizen.Wait(10000)

    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("prison:server:completeJob", jobName)
    isWorking = false
end
