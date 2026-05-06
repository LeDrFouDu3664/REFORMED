local hasEscapeTool = false
local escapeLocation = vector3(1705.0, 2565.0, 45.0)

RegisterNetEvent("prison:client:receiveEscapeTool")
AddEventHandler("prison:client:receiveEscapeTool", function()
    hasEscapeTool = true
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        local dist = #(pos - escapeLocation)
        if dist < 10.0 then
            sleep = 0
            DrawMarker(1, escapeLocation.x, escapeLocation.y, escapeLocation.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)

            if dist < 1.5 then
                if hasEscapeTool then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Appuyez sur ~INPUT_CONTEXT~ pour vous évader")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustReleased(0, 38) then -- E
                        StartEscape()
                    end
                else
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("La porte est verrouillée. Il vous faut un outil.")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

function StartEscape()
    hasEscapeTool = false -- Consume tool

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, true)

    SendNUIMessage({
        action = "startProgress",
        duration = 15000,
        label = "Évasion en cours..."
    })

    Citizen.Wait(15000)
    ClearPedTasks(PlayerPedId())

    TriggerServerEvent("prison:server:executeEscape")
end
