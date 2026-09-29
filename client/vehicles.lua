local spawnedVehicles = {}

-- Helper function to spawn and damage an abandoned vehicle
local function SpawnAbandonedVehicle(data)
    local modelHash = GetHashKey(data.model or 'rubble')
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return nil end

    local coords = GetVector3Coords(data.coords)
    local heading = (data.heading or 0.0) + 0.0

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, false, false)

    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)

        -- Apply abandoned & damaged state
        SetVehicleEngineHealth(vehicle, 0.0)
        SetVehicleBodyHealth(vehicle, 100.0)
        SetVehicleUndriveable(vehicle, true)
        SetVehicleDoorsLocked(vehicle, 2) -- Locked
        SetVehicleDirtLevel(vehicle, 15.0)

        -- Random flat tires & damage deformation
        SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
        SetVehicleTyreBurst(vehicle, 4, true, 1000.0)
        SetVehicleDamage(vehicle, 0.0, 0.0, 0.3, 1000.0, 250.0, true)

        spawnedVehicles[data.id] = vehicle
    end

    SetModelAsNoLongerNeeded(modelHash)
    return vehicle
end

-- Manage Spawned Vehicles Streamed in Range
CreateThread(function()
    while true do
        local sleep = 1000
        local pCoords = GetEntityCoords(PlayerPedId())

        for _, vData in ipairs(Vehicles) do
            local vCoords = GetVector3Coords(vData.coords)
            local dist = #(pCoords - vCoords)

            -- Stream in within 200 units
            if dist <= 200.0 then
                if not spawnedVehicles[vData.id] or not DoesEntityExist(spawnedVehicles[vData.id]) then
                    SpawnAbandonedVehicle(vData)
                end
            else
                if spawnedVehicles[vData.id] and DoesEntityExist(spawnedVehicles[vData.id]) then
                    DeleteVehicle(spawnedVehicles[vData.id])
                    spawnedVehicles[vData.id] = nil
                end
            end
        end

        Wait(sleep)
    end
end)

-- Clean up streamed vehicles on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for id, veh in pairs(spawnedVehicles) do
        if DoesEntityExist(veh) then
            DeleteVehicle(veh)
        end
    end
end)
