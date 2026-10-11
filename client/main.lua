local QBCore = exports['qb-core']:GetCoreObject()
local inventoryOpen = false

-- =========================================================================
-- MOCK BACKEND CLIENT LOGIC
-- =========================================================================
-- WARNING: This is a skeleton meant for UI testing purposes only.
-- Do NOT use this file in a live server, as it does not actually handle item usage, drops, stashes, etc.
-- =========================================================================

-- Open Inventory command/keybind
RegisterCommand('inventory', function()
    if not inventoryOpen then
        OpenInventory()
    else
        CloseInventory()
    end
end)

RegisterKeyMapping('inventory', 'Open Inventory', 'keyboard', 'TAB')

function OpenInventory()
    inventoryOpen = true
    SetNuiFocus(true, true)

    local playerData = QBCore.Functions.GetPlayerData()
    local weight = 0
    local maxWeight = QBCore.Config.Player.MaxWeight or 120000

    -- Calculate current weight (mock calculation if weight isn't natively exposed in metadata easily, normally server sends this)
    if playerData.items then
        for _, item in pairs(playerData.items) do
            if item then
                weight = weight + (item.weight * item.amount)
            end
        end
    end

    -- Send mock/actual data to NUI
    SendNUIMessage({
        action = "open",
        playerName = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname,
        weight = weight,
        maxWeight = maxWeight,
        inventory = playerData.items
    })
end

function CloseInventory()
    inventoryOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "close"
    })
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseInventory()
    cb('ok')
end)

RegisterNUICallback('moveItem', function(data, cb)
    -- Send to server to handle logic
    TriggerServerEvent('qb-inventory:server:moveItem', data.fromSlot, data.toSlot, data.fromInv, data.toInv)
    cb('ok')
end)

RegisterNUICallback('equipItem', function(data, cb)
    TriggerServerEvent('qb-inventory:server:equipItem', data.fromSlot, data.type)
    cb('ok')
end)

RegisterNUICallback('useItem', function(data, cb)
    -- Implement use item logic (usually requires knowing which slot is selected)
    TriggerServerEvent('qb-inventory:server:useItem')
    cb('ok')
end)

RegisterNUICallback('giveItem', function(data, cb)
    TriggerServerEvent('qb-inventory:server:giveItem')
    cb('ok')
end)

RegisterNUICallback('dropItem', function(data, cb)
    TriggerServerEvent('qb-inventory:server:dropItem')
    cb('ok')
end)
