local ESX = nil
local QBCore = nil

-- Framework Initialization
if Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    if not ESX then
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
    end
elseif Config.Framework == 'qbcore' then
    pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
end

-- Persistence File Path
local dataFilePath = 'data/zones.json'

local zonesData = {}
local vehiclesData = {}
local globalHalloween = false

-- Function to load data from JSON file
local function LoadDataFromFile()
    local fileContent = LoadResourceFile(GetCurrentResourceName(), dataFilePath)
    if fileContent and fileContent ~= "" then
        local decoded = json.decode(fileContent)
        if decoded then
            zonesData = decoded.zones or {}
            vehiclesData = decoded.vehicles or {}
            globalHalloween = decoded.globalHalloween or false
            print(('^2[zombie_zones]^7 Charger avec succès %d zone(s) et %d véhicule(s) abandonné(s).'):format(#zonesData, #vehiclesData))
            return
        end
    end

    -- Fallback to default zones from Config if JSON file does not exist or is empty
    zonesData = Config.DefaultZones or {}
    vehiclesData = {}
    globalHalloween = false
    print('^3[zombie_zones]^7 Fichier de données non trouvé. Chargement des zones par défaut du Config.^7')
end

-- Function to save data to JSON file
local function SaveDataToFile()
    local payload = {
        zones = zonesData,
        vehicles = vehiclesData,
        globalHalloween = globalHalloween
    }
    SaveResourceFile(GetCurrentResourceName(), dataFilePath, json.encode(payload, { indent = true }), -1)
end

-- Admin Permission Checker
local function IsPlayerAdmin(source)
    if source == 0 then return true end -- Server console

    if Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            if Config.AdminGroups[group] then
                return true
            end
        end
    elseif Config.Framework == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for group, allowed in pairs(Config.AdminGroups) do
                if allowed and QBCore.Functions.HasPermission(source, group) then
                    return true
                end
            end
        end
    end

    -- Standalone / ACE Permission fallback
    return IsPlayerAceAllowed(source, 'command.' .. Config.AdminCommand) or IsPlayerAceAllowed(source, 'zombie_zones.admin')
end

-- Initialize Data on Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    LoadDataFromFile()
end)

-- Sync Initial Data to Client when spawned
RegisterNetEvent('zombie_zones:server:requestData', function()
    local src = source
    TriggerClientEvent('zombie_zones:client:syncAllData', src, zonesData, vehiclesData, globalHalloween)
end)

-- Command to open Admin Panel
RegisterCommand(Config.AdminCommand, function(source, args, rawCommand)
    if IsPlayerAdmin(source) then
        TriggerClientEvent('zombie_zones:client:openAdminMenu', source, zonesData, vehiclesData, globalHalloween)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Zombie Zones]", Config.Language['no_permission']}
        })
    end
end, false)

-- Server Event: Create Zone
RegisterNetEvent('zombie_zones:server:createZone', function(zoneData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local newId = "zone_" .. os.time() .. "_" .. math.random(100, 999)
    zoneData.id = newId
    zoneData.active = true
    zoneData.coords = { x = zoneData.coords.x, y = zoneData.coords.y, z = zoneData.coords.z }

    table.insert(zonesData, zoneData)
    SaveDataToFile()

    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        args = {"[Zombie Zones]", Config.Language['zone_created']}
    })
end)

-- Server Event: Update Zone
RegisterNetEvent('zombie_zones:server:updateZone', function(updatedZone)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, zone in ipairs(zonesData) do
        if zone.id == updatedZone.id then
            zonesData[i] = updatedZone
            break
        end
    end

    SaveDataToFile()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        args = {"[Zombie Zones]", Config.Language['zone_updated']}
    })
end)

-- Server Event: Toggle Zone Active State
RegisterNetEvent('zombie_zones:server:toggleZone', function(zoneId, state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, zone in ipairs(zonesData) do
        if zone.id == zoneId then
            zonesData[i].active = state
            break
        end
    end

    SaveDataToFile()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
end)

-- Server Event: Delete Zone
RegisterNetEvent('zombie_zones:server:deleteZone', function(zoneId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, zone in ipairs(zonesData) do
        if zone.id == zoneId then
            table.remove(zonesData, i)
            break
        end
    end

    SaveDataToFile()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 100, 0},
        args = {"[Zombie Zones]", Config.Language['zone_deleted']}
    })
end)

-- Server Event: Place Abandoned Vehicle
RegisterNetEvent('zombie_zones:server:placeVehicle', function(vehData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local vehId = "veh_" .. os.time() .. "_" .. math.random(100, 999)
    vehData.id = vehId

    table.insert(vehiclesData, vehData)
    SaveDataToFile()

    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        args = {"[Zombie Zones]", Config.Language['vehicle_placed']}
    })
end)

-- Server Event: Delete Abandoned Vehicle
RegisterNetEvent('zombie_zones:server:deleteVehicle', function(vehId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, veh in ipairs(vehiclesData) do
        if veh.id == vehId then
            table.remove(vehiclesData, i)
            break
        end
    end

    SaveDataToFile()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 100, 0},
        args = {"[Zombie Zones]", Config.Language['vehicle_deleted']}
    })
end)

-- Server Event: Toggle Halloween Event
RegisterNetEvent('zombie_zones:server:toggleHalloween', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    globalHalloween = state
    SaveDataToFile()

    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    local msg = state and Config.Language['halloween_enabled'] or Config.Language['halloween_disabled']
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 128, 0},
        args = {"[Événement Zombie]", msg}
    })
end)
