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

-- Persistence File Path (JSON Fallback)
local dataFilePath = 'data/zones.json'

local zonesData = {}
local vehiclesData = {}
local propsData = {}
local globalHalloween = false

-- Database Persistence Handler (SQL or JSON)
local function LoadData()
    if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        MySQL.query('SELECT * FROM zombie_zones', {}, function(zones)
            if zones and #zones > 0 then
                zonesData = {}
                for _, z in ipairs(zones) do
                    table.insert(zonesData, {
                        id = z.id,
                        name = z.name,
                        coords = json.decode(z.coords),
                        radius = z.radius,
                        active = z.active == 1,
                        zombieMax = z.zombieMax,
                        zombieHealth = z.zombieHealth,
                        zombieSpeed = z.zombieSpeed,
                        zombieDamage = z.zombieDamage,
                        weather = z.weather,
                        halloween = z.halloween == 1,
                        blip = z.blip and json.decode(z.blip) or nil
                    })
                end
            else
                zonesData = Config.DefaultZones or {}
            end
        end)

        MySQL.query('SELECT * FROM zombie_vehicles', {}, function(vehs)
            vehiclesData = {}
            if vehs then
                for _, v in ipairs(vehs) do
                    table.insert(vehiclesData, {
                        id = v.id,
                        model = v.model,
                        coords = json.decode(v.coords),
                        heading = v.heading
                    })
                end
            end
        end)

        MySQL.query('SELECT * FROM zombie_props', {}, function(props)
            propsData = {}
            if props then
                for _, p in ipairs(props) do
                    table.insert(propsData, {
                        id = p.id,
                        model = p.model,
                        coords = json.decode(p.coords),
                        heading = p.heading,
                        owner = p.owner
                    })
                end
            end
        end)
        print('^2[zombie_zones]^7 Données chargées avec succès depuis la base de données SQL (oxmysql).^7')
    else
        -- JSON Fallback
        local fileContent = LoadResourceFile(GetCurrentResourceName(), dataFilePath)
        if fileContent and fileContent ~= "" then
            local decoded = json.decode(fileContent)
            if decoded then
                zonesData = decoded.zones or Config.DefaultZones
                vehiclesData = decoded.vehicles or {}
                propsData = decoded.props or {}
                globalHalloween = decoded.globalHalloween or false
                print('^2[zombie_zones]^7 Données chargées depuis data/zones.json.^7')
                return
            end
        end
        zonesData = Config.DefaultZones or {}
        vehiclesData = {}
        propsData = {}
    end
end

local function SaveData()
    if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        -- Async SQL Sync
        for _, z in ipairs(zonesData) do
            MySQL.insert('INSERT INTO zombie_zones (id, name, coords, radius, active, zombieMax, zombieHealth, zombieSpeed, zombieDamage, weather, halloween, blip) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, coords=?, radius=?, active=?, zombieMax=?, zombieHealth=?, zombieSpeed=?, zombieDamage=?, weather=?, halloween=?, blip=?', {
                z.id, z.name, json.encode(z.coords), z.radius, z.active and 1 or 0, z.zombieMax or 20, z.zombieHealth or 150, z.zombieSpeed or 1.2, z.zombieDamage or 15, z.weather or 'HALLOWEEN', z.halloween and 1 or 0, json.encode(z.blip or {}),
                z.name, json.encode(z.coords), z.radius, z.active and 1 or 0, z.zombieMax or 20, z.zombieHealth or 150, z.zombieSpeed or 1.2, z.zombieDamage or 15, z.weather or 'HALLOWEEN', z.halloween and 1 or 0, json.encode(z.blip or {})
            })
        end
    end

    -- Always save to JSON fallback
    local payload = {
        zones = zonesData,
        vehicles = vehiclesData,
        props = propsData,
        globalHalloween = globalHalloween
    }
    SaveResourceFile(GetCurrentResourceName(), dataFilePath, json.encode(payload, { indent = true }), -1)
end

-- Admin Permission Checker
local function IsPlayerAdmin(source)
    if source == 0 then return true end

    if Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            if Config.AdminGroups[group] then return true end
        end
    elseif Config.Framework == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for group, allowed in pairs(Config.AdminGroups) do
                if allowed and QBCore.Functions.HasPermission(source, group) then return true end
            end
        end
    end

    return IsPlayerAceAllowed(source, 'command.' .. Config.AdminCommand) or IsPlayerAceAllowed(source, 'zombie_zones.admin')
end

-- Initialize Data on Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    LoadData()
end)

-- Sync Initial Data to Client when spawned
RegisterNetEvent('zombie_zones:server:requestData', function()
    local src = source
    TriggerClientEvent('zombie_zones:client:syncAllData', src, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('zombie_zones:client:syncProps', src, propsData)

    -- Sync Player Infection Level from DB
    local identifier = GetPlayerIdentifier(src, 0)
    if identifier and Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        MySQL.single('SELECT * FROM zombie_player_infection WHERE identifier = ?', { identifier }, function(row)
            if row then
                TriggerClientEvent('zombie_zones:client:syncInfection', src, row.infection, row.stage, row.transformed == 1)
            end
        end)
    end
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

-- Save Player Infection Level
RegisterNetEvent('zombie_zones:server:savePlayerInfection', function(level, stage, transformed)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    if not identifier then return end

    if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        MySQL.insert('INSERT INTO zombie_player_infection (identifier, infection, stage, transformed) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE infection=?, stage=?, transformed=?', {
            identifier, level, stage, transformed and 1 or 0,
            level, stage, transformed and 1 or 0
        })
    end
end)

-- Server Event: Create Zone
RegisterNetEvent('zombie_zones:server:createZone', function(zoneData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local newId = "zone_" .. os.time() .. "_" .. math.random(100, 999)
    zoneData.id = newId
    zoneData.active = true
    zoneData.coords = { x = zoneData.coords.x, y = zoneData.coords.y, z = zoneData.coords.z }

    table.insert(zonesData, zoneData)
    SaveData()

    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, { color = {0, 255, 0}, args = {"[Zombie Zones]", Config.Language['zone_created']} })
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

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, { color = {0, 255, 0}, args = {"[Zombie Zones]", Config.Language['zone_updated']} })
end)

-- Server Event: Toggle Zone
RegisterNetEvent('zombie_zones:server:toggleZone', function(zoneId, state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, zone in ipairs(zonesData) do
        if zone.id == zoneId then
            zonesData[i].active = state
            break
        end
    end

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
end)

-- Server Event: Delete Zone
RegisterNetEvent('zombie_zones:server:deleteZone', function(zoneId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, zone in ipairs(zonesData) do
        if zone.id == zoneId then
            if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
                MySQL.query('DELETE FROM zombie_zones WHERE id = ?', { zoneId })
            end
            table.remove(zonesData, i)
            break
        end
    end

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, { color = {255, 100, 0}, args = {"[Zombie Zones]", Config.Language['zone_deleted']} })
end)

-- Server Event: Place Abandoned Vehicle
RegisterNetEvent('zombie_zones:server:placeVehicle', function(vehData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local vehId = "veh_" .. os.time() .. "_" .. math.random(100, 999)
    vehData.id = vehId

    table.insert(vehiclesData, vehData)

    if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        MySQL.insert('INSERT INTO zombie_vehicles (id, model, coords, heading) VALUES (?, ?, ?, ?)', {
            vehId, vehData.model, json.encode(vehData.coords), vehData.heading
        })
    end

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, { color = {0, 255, 0}, args = {"[Zombie Zones]", Config.Language['vehicle_placed']} })
end)

-- Server Event: Delete Vehicle
RegisterNetEvent('zombie_zones:server:deleteVehicle', function(vehId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    for i, veh in ipairs(vehiclesData) do
        if veh.id == vehId then
            if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
                MySQL.query('DELETE FROM zombie_vehicles WHERE id = ?', { vehId })
            end
            table.remove(vehiclesData, i)
            break
        end
    end

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    TriggerClientEvent('chat:addMessage', src, { color = {255, 100, 0}, args = {"[Zombie Zones]", Config.Language['vehicle_deleted']} })
end)

-- Server Event: Place Prop
RegisterNetEvent('zombie_zones:server:placeProp', function(propData)
    local src = source

    local propId = "prop_" .. os.time() .. "_" .. math.random(100, 999)
    propData.id = propId
    propData.owner = GetPlayerIdentifier(src, 0)

    table.insert(propsData, propData)

    if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
        MySQL.insert('INSERT INTO zombie_props (id, model, coords, heading, owner) VALUES (?, ?, ?, ?, ?)', {
            propId, propData.model, json.encode(propData.coords), propData.heading, propData.owner
        })
    end

    SaveData()
    TriggerClientEvent('zombie_zones:client:syncProps', -1, propsData)
    TriggerClientEvent('chat:addMessage', src, { color = {0, 255, 0}, args = {"[Zombie Zones]", Config.Language['prop_placed']} })
end)

-- Server Event: Delete Prop (With Admin & Ownership Verification)
RegisterNetEvent('zombie_zones:server:deleteProp', function(propId)
    local src = source
    local playerIdentifier = GetPlayerIdentifier(src, 0)
    local isAdmin = IsPlayerAdmin(src)

    for i, prop in ipairs(propsData) do
        if prop.id == propId then
            if isAdmin or (prop.owner and prop.owner == playerIdentifier) then
                if Config.DatabaseType == 'oxmysql' and GetResourceState('oxmysql') == 'started' then
                    MySQL.query('DELETE FROM zombie_props WHERE id = ?', { propId })
                end
                table.remove(propsData, i)
                SaveData()
                TriggerClientEvent('zombie_zones:client:syncProps', -1, propsData)
                TriggerClientEvent('chat:addMessage', src, { color = {255, 100, 0}, args = {"[Zombie Zones]", Config.Language['prop_deleted']} })
            else
                TriggerClientEvent('chat:addMessage', src, { color = {255, 0, 0}, args = {"[Zombie Zones]", Config.Language['no_permission']} })
            end
            break
        end
    end
end)

-- Server Event: Toggle Halloween
RegisterNetEvent('zombie_zones:server:toggleHalloween', function(state)
    local src = source
    if not IsPlayerAdmin(src) then return end

    globalHalloween = state
    SaveData()

    TriggerClientEvent('zombie_zones:client:syncAllData', -1, zonesData, vehiclesData, globalHalloween)
    local msg = state and Config.Language['halloween_enabled'] or Config.Language['halloween_disabled']
    TriggerClientEvent('chat:addMessage', -1, { color = {255, 128, 0}, args = {"[Événement Zombie]", msg} })
end)
