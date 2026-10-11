local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================================
-- MOCK BACKEND SERVER LOGIC
-- =========================================================================
-- WARNING: This is a skeleton meant for UI testing purposes only.
-- Do NOT use this file in a live server, as it does not actually manage items.
-- =========================================================================

-- Server-side drag and drop logic handler
RegisterNetEvent('qb-inventory:server:moveItem', function(fromSlot, toSlot, fromInv, toInv)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Example implementation skeleton, normally integrates tightly with qb-inventory core
    -- This handles moving within player inventory, or between player and other inventories (stash/trunk)
    -- In a real QBCore environment, this would call QBCore.Functions.MoveItem or similar logic

    print(("Player %s moved item from slot %s in %s to slot %s in %s"):format(src, fromSlot, fromInv, toSlot, toInv))

    -- Sync updated inventory back to client
    -- TriggerClientEvent('qb-inventory:client:UpdateInventory', src)
end)

RegisterNetEvent('qb-inventory:server:equipItem', function(fromSlot, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    print(("Player %s equipped item from slot %s to %s"):format(src, fromSlot, type))
    -- Implement equip logic here (e.g. putting on clothes or taking out a weapon)
end)

RegisterNetEvent('qb-inventory:server:useItem', function()
    local src = source
    -- Logic to use currently selected item
    print(("Player %s used an item"):format(src))
end)

RegisterNetEvent('qb-inventory:server:giveItem', function()
    local src = source
    -- Logic to give item to nearest player
    print(("Player %s gave an item"):format(src))
end)

RegisterNetEvent('qb-inventory:server:dropItem', function()
    local src = source
    -- Logic to drop item on the ground
    print(("Player %s dropped an item"):format(src))
end)
