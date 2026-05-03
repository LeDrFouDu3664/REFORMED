local vendorPed = nil
local vendorCoords = nil

RegisterNetEvent("prison:client:syncVendor")
AddEventHandler("prison:client:syncVendor", function(coords)
    vendorCoords = coords
    SpawnVendor()
end)

function SpawnVendor()
    if vendorPed then
        DeleteEntity(vendorPed)
        vendorPed = nil
    end

    if not vendorCoords then return end

    Citizen.CreateThread(function()
        local model = GetHashKey(Config.Peds.VendorModel)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        vendorPed = CreatePed(4, model, vendorCoords.x, vendorCoords.y, vendorCoords.z - 1.0, 0.0, false, true)
        SetEntityAsMissionEntity(vendorPed, true, true)
        SetEntityInvincible(vendorPed, true)
        SetBlockingOfNonTemporaryEvents(vendorPed, true)
        FreezeEntityPosition(vendorPed, true)

        -- ox_target or qb-target logic can go here for interaction
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    TriggerServerEvent("prison:server:requestVendor")

    while true do
        Citizen.Wait(1000)
        if vendorCoords then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            if #(pos - vendorCoords) < 2.0 then
                -- Display interaction
                SetTextComponentFormat("STRING")
                AddTextComponentString("Appuyez sur ~INPUT_CONTEXT~ pour parler au vendeur")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                if IsControlJustReleased(0, 38) then
                    -- Open Vendor Menu
                    print("[Prison] Ouverture du menu vendeur")
                end
            end
        end
    end
end)
