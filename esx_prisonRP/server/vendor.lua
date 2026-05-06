local activeVendorCoords = nil

Citizen.CreateThread(function()
    -- Initialize on start
    math.randomseed(os.time())

    while true do
        local spawns = Config.Locations.VendorSpawns
        local index = math.random(1, #spawns)
        activeVendorCoords = spawns[index]

        TriggerClientEvent("prison:client:syncVendor", -1, activeVendorCoords)

        -- Wait 24 hours (86400000 ms) before moving vendor again
        Citizen.Wait(86400000)
    end
end)

RegisterNetEvent("prison:server:requestVendor")
AddEventHandler("prison:server:requestVendor", function()
    if activeVendorCoords then
        TriggerClientEvent("prison:client:syncVendor", source, activeVendorCoords)
    end
end)
