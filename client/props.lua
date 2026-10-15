Props = {}
local spawnedProps = {}

-- Helper: Convert vector / table coords to vector3
local function GetVector3Coords(coords)
    if type(coords) == 'vector3' then return coords end
    if type(coords) == 'table' and coords.x and coords.y and coords.z then
        return vector3(coords.x, coords.y, coords.z)
    end
    return vector3(0.0, 0.0, 0.0)
end

-- Spawn a single prop entity locally
local function SpawnPropEntity(data)
    local modelHash = GetHashKey(data.model or 'prop_barrier_work05')
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return nil end

    local coords = GetVector3Coords(data.coords)
    local heading = (data.heading or 0.0) + 0.0

    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)

    if DoesEntityExist(prop) then
        SetEntityHeading(prop, heading)
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)
        SetEntityAsMissionEntity(prop, true, true)
        spawnedProps[data.id] = prop
    end

    SetModelAsNoLongerNeeded(modelHash)
    return prop
end

-- Receive props sync from server
RegisterNetEvent('zombie_zones:client:syncProps', function(propsData)
    Props = propsData or {}
end)

-- Stream props in range thread
CreateThread(function()
    while true do
        local sleep = 1000
        local pCoords = GetEntityCoords(PlayerPedId())

        for _, pData in ipairs(Props) do
            local coords = GetVector3Coords(pData.coords)
            local dist = #(pCoords - coords)

            if dist <= 150.0 then
                if not spawnedProps[pData.id] or not DoesEntityExist(spawnedProps[pData.id]) then
                    SpawnPropEntity(pData)
                end
            else
                if spawnedProps[pData.id] and DoesEntityExist(spawnedProps[pData.id]) then
                    DeleteObject(spawnedProps[pData.id])
                    spawnedProps[pData.id] = nil
                end
            end
        end

        Wait(sleep)
    end
end)

-- Clean up spawned props on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for id, prop in pairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end
end)
