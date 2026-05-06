RegisterNetEvent("prison:client:jailLogin")
AddEventHandler("prison:client:jailLogin", function(jailTime)
    local ped = PlayerPedId()
    local spawn = Config.Locations.JailSpawn

    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, 0.0, true, false)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)

    TriggerEvent("chat:addMessage", { args = { '^1[Prison]', 'Vous purgez actuellement une peine de ' .. jailTime .. ' minutes.' } })
end)
