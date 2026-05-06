RegisterNetEvent("prison:client:release")
AddEventHandler("prison:client:release", function()
    local ped = PlayerPedId()
    local releaseSpawn = Config.Locations.ReleaseSpawn

    -- Load map collision before teleporting
    RequestCollisionAtCoord(releaseSpawn.x, releaseSpawn.y, releaseSpawn.z)
    SetEntityCoordsNoOffset(ped, releaseSpawn.x, releaseSpawn.y, releaseSpawn.z, false, false, false, true)
    NetworkResurrectLocalPlayer(releaseSpawn.x, releaseSpawn.y, releaseSpawn.z, 0.0, true, false)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)

    if GetFramework() == "esx" then
        TriggerServerEvent('prison:server:restoreJob')
    end
end)
