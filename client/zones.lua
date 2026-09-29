Zones = {}
Vehicles = {}
GlobalHalloween = false
CurrentZone = nil

local zoneBlips = {}
local zoneRadiusBlips = {}

-- Sync data from server
RegisterNetEvent('zombie_zones:client:syncAllData', function(zonesData, vehiclesData, globalHalloweenState)
    Zones = zonesData or {}
    Vehicles = vehiclesData or {}
    GlobalHalloween = globalHalloweenState or false

    UpdateZoneBlips()
end)

-- Request initial data when player loads
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('zombie_zones:server:requestData')
end)

CreateThread(function()
    TriggerServerEvent('zombie_zones:server:requestData')
end)

-- Helper: Convert vector / table coords to vector3
function GetVector3Coords(coords)
    if type(coords) == 'vector3' then return coords end
    if type(coords) == 'table' and coords.x and coords.y and coords.z then
        return vector3(coords.x, coords.y, coords.z)
    end
    return vector3(0.0, 0.0, 0.0)
end

-- Manage Map Blips for Infection Zones
function UpdateZoneBlips()
    -- Clear old blips
    for _, blip in pairs(zoneBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    for _, blip in pairs(zoneRadiusBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    zoneBlips = {}
    zoneRadiusBlips = {}

    for _, zone in ipairs(Zones) do
        if zone.active then
            local pos = GetVector3Coords(zone.coords)

            -- Center Icon Blip
            local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
            SetBlipSprite(blip, (zone.blip and zone.blip.sprite) or 436)
            SetBlipColour(blip, (zone.blip and zone.blip.color) or 1)
            SetBlipScale(blip, (zone.blip and zone.blip.scale) or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString((zone.blip and zone.blip.label) or zone.name or "Zone Infectée")
            EndTextCommandSetBlipName(blip)
            table.insert(zoneBlips, blip)

            -- Radius Area Blip
            local radiusBlip = AddBlipForRadius(pos.x, pos.y, pos.z, zone.radius + 0.0)
            SetBlipColour(radiusBlip, 1) -- Red
            SetBlipAlpha(radiusBlip, 120)
            table.insert(zoneRadiusBlips, radiusBlip)
        end
    end
end

-- Main Zone Detection & Ambient Population Suppression Loop
CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        local inZone = nil

        for _, zone in ipairs(Zones) do
            if zone.active then
                local zCoords = GetVector3Coords(zone.coords)
                local dist = #(pCoords - zCoords)

                if dist <= zone.radius then
                    inZone = zone
                    break
                end
            end
        end

        -- Check Zone State Change
        if inZone and not CurrentZone then
            CurrentZone = inZone
            TriggerEvent('chat:addMessage', {
                color = {255, 50, 50},
                args = {"[Zombie Zones]", Config.Language['zone_entered']}
            })
            TriggerEvent('zombie_zones:client:onEnterZone', CurrentZone)
        elseif not inZone and CurrentZone then
            TriggerEvent('chat:addMessage', {
                color = {50, 255, 50},
                args = {"[Zombie Zones]", Config.Language['zone_exited']}
            })
            TriggerEvent('zombie_zones:client:onExitZone', CurrentZone)
            CurrentZone = nil
        elseif inZone and CurrentZone and CurrentZone.id ~= inZone.id then
            TriggerEvent('zombie_zones:client:onExitZone', CurrentZone)
            CurrentZone = inZone
            TriggerEvent('zombie_zones:client:onEnterZone', CurrentZone)
        end

        -- If inside active zone, clear ambient population
        if CurrentZone then
            sleep = 0

            -- Suppress native traffic & peds
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)

            -- Clear area of default ambient peds and traffic vehicles periodically
            local zCoords = GetVector3Coords(CurrentZone.coords)
            SuppressChargeForGridArea(zCoords.x - CurrentZone.radius, zCoords.y - CurrentZone.radius, zCoords.x + CurrentZone.radius, zCoords.y + CurrentZone.radius)
            RemoveVehiclesInArea(zCoords.x, zCoords.y, zCoords.z, CurrentZone.radius)
        end

        Wait(sleep)
    end
end)
