local isAdminOpen = false

-- Event to open admin menu called from server
RegisterNetEvent('zombie_zones:client:openAdminMenu', function(zonesData, vehiclesData, globalHalloweenState)
    isAdminOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        type = 'openAdmin',
        zones = zonesData or {},
        vehicles = vehiclesData or {},
        globalHalloween = globalHalloweenState or false
    })
end)

-- NUI Callback: Close UI
RegisterNUICallback('closeUI', function(data, cb)
    isAdminOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- NUI Callback: Create Zone at Player Position
RegisterNUICallback('createZoneHere', function(data, cb)
    local pCoords = GetEntityCoords(PlayerPedId())

    local zoneData = {
        name = "Zone " .. math.random(1000, 9999),
        coords = { x = pCoords.x, y = pCoords.y, z = pCoords.z },
        radius = (data.radius or 150.0) + 0.0,
        zombieMax = data.zombieMax or 20,
        zombieHealth = data.zombieHealth or 150,
        zombieSpeed = data.zombieSpeed or 1.2,
        zombieDamage = data.zombieDamage or 15,
        weather = Config.Ambiance.DefaultWeather,
        halloween = false,
        blip = {
            sprite = 436,
            color = 1,
            scale = 0.8,
            label = "Zone Infectée"
        }
    }

    TriggerServerEvent('zombie_zones:server:createZone', zoneData)
    cb('ok')
end)

-- NUI Callback: Update Existing Zone
RegisterNUICallback('updateZone', function(data, cb)
    if data and data.id then
        TriggerServerEvent('zombie_zones:server:updateZone', data)
    end
    cb('ok')
end)

-- NUI Callback: Toggle Zone Active State
RegisterNUICallback('toggleZone', function(data, cb)
    if data.id then
        TriggerServerEvent('zombie_zones:server:toggleZone', data.id, data.state)
    end
    cb('ok')
end)

-- NUI Callback: Delete Zone
RegisterNUICallback('deleteZone', function(data, cb)
    if data.id then
        TriggerServerEvent('zombie_zones:server:deleteZone', data.id)
    end
    cb('ok')
end)

-- NUI Callback: Place Vehicle at Player Position
RegisterNUICallback('placeVehicleHere', function(data, cb)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehData = {
        model = data.model or 'rubble',
        coords = { x = pCoords.x, y = pCoords.y, z = pCoords.z },
        heading = heading
    }

    TriggerServerEvent('zombie_zones:server:placeVehicle', vehData)
    cb('ok')
end)

-- NUI Callback: Delete Vehicle
RegisterNUICallback('deleteVehicle', function(data, cb)
    if data.id then
        TriggerServerEvent('zombie_zones:server:deleteVehicle', data.id)
    end
    cb('ok')
end)

-- NUI Callback: Toggle Halloween Event
RegisterNUICallback('toggleHalloween', function(data, cb)
    TriggerServerEvent('zombie_zones:server:toggleHalloween', data.state)
    cb('ok')
end)
