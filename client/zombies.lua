local spawnedZombies = {}
local isSpawningZombies = false

-- Helper: Get random offset position within circle radius
local function GetRandomCoordInZone(zoneCoords, radius)
    local angle = math.random() * 2 * math.pi
    local r = math.sqrt(math.random()) * (radius * 0.8)
    local x = zoneCoords.x + r * math.cos(angle)
    local y = zoneCoords.y + r * math.sin(angle)

    local found, z = GetGroundZFor_3dCoord(x, y, zoneCoords.z + 50.0, true)
    if not found then z = zoneCoords.z end

    return vector3(x, y, z)
end

-- Load animation dictionary helper
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Helper: Setup Zombie Ped AI & Attributes
local function ConfigureZombiePed(ped, zone)
    -- Multipliers if Halloween is active
    local healthMult = (GlobalHalloween or zone.halloween) and Config.Halloween.ZombieHealthMultiplier or 1.0
    local speedMult = (GlobalHalloween or zone.halloween) and Config.Halloween.ZombieSpeedMultiplier or 1.0
    local damageMult = (GlobalHalloween or zone.halloween) and Config.Halloween.ZombieDamageMultiplier or 1.0

    local baseHealth = (zone.zombieHealth or Config.Zombies.DefaultHealth) * healthMult
    local baseSpeed = (zone.zombieSpeed or Config.Zombies.DefaultSpeed) * speedMult

    SetEntityHealth(ped, math.floor(baseHealth))
    SetPedMaxHealth(ped, math.floor(baseHealth))

    -- Voice & Pain audio
    SetAmbientVoiceName(ped, "ALIENS")
    SetPedAudioSpecialEffectMode(ped, 2)

    -- Combat & AI Attributes
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true) -- Always fight
    SetPedCombatAttributes(ped, 5, true)  -- Keep fighting
    SetPedCombatAttributes(ped, 0, true)  -- Can use cover false
    SetPedSeeingRange(ped, Config.Zombies.TargetDetectDistance)
    SetPedHearingRange(ped, Config.Zombies.TargetDetectDistance)
    SetPedAlertness(ped, 3)
    SetPedIsDrunk(ped, true)
    SetPedAccuracy(ped, 25)

    -- Walk Animation Clipset
    local walkStyle = Config.Zombies.WalkStyles[math.random(#Config.Zombies.WalkStyles)]
    RequestAnimSet(walkStyle)
    while not HasAnimSetLoaded(walkStyle) do Wait(10) end
    SetPedMovementClipset(ped, walkStyle, 1.0)

    -- Set Movement Speed
    SetAnimRate(ped, baseSpeed, 0.0, false)
    SetPedMoveRateOverride(ped, baseSpeed)

    return damageMult
end

-- Spawn Zombie in Zone (isNetwork = false to avoid duplicate network peds across clients)
local function SpawnZombieInZone(zone)
    local modelName = Config.Zombies.Models[math.random(#Config.Zombies.Models)]
    local modelHash = GetHashKey(modelName)

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return nil end

    local spawnPos = GetRandomCoordInZone(GetVector3Coords(zone.coords), zone.radius)
    local ped = CreatePed(4, modelHash, spawnPos.x, spawnPos.y, spawnPos.z, math.random(0, 360) + 0.0, false, false)

    if DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        local damageMult = ConfigureZombiePed(ped, zone)
        table.insert(spawnedZombies, { ped = ped, zoneId = zone.id, isDead = false, nextAttack = 0, damageMult = damageMult })
    end

    SetModelAsNoLongerNeeded(modelHash)
    return ped
end

-- Manage Zombies Spawning inside Zone
RegisterNetEvent('zombie_zones:client:onEnterZone', function(zone)
    isSpawningZombies = true

    local maxZombies = (zone.zombieMax or Config.Zombies.DefaultMaxCount)
    if GlobalHalloween or zone.halloween then
        maxZombies = math.floor(maxZombies * Config.Halloween.ZombieCountMultiplier)
    end

    CreateThread(function()
        while isSpawningZombies and CurrentZone and CurrentZone.id == zone.id do
            -- Filter out cleaned or deleted zombies
            local activeCount = 0
            for i = #spawnedZombies, 1, -1 do
                local z = spawnedZombies[i]
                if not DoesEntityExist(z.ped) then
                    table.remove(spawnedZombies, i)
                else
                    if not z.isDead then
                        activeCount = activeCount + 1
                    end
                end
            end

            -- Maintain zombie count up to limit
            if activeCount < maxZombies then
                SpawnZombieInZone(zone)
            end

            Wait(2000)
        end
    end)
end)

-- Clean up Zombies when exiting zone
RegisterNetEvent('zombie_zones:client:onExitZone', function(zone)
    isSpawningZombies = false

    for i = #spawnedZombies, 1, -1 do
        local z = spawnedZombies[i]
        if DoesEntityExist(z.ped) then
            DeleteEntity(z.ped)
        end
    end
    spawnedZombies = {}
end)

-- Main Zombie AI Behavior, Chase, Attack & Respawn Thread
CreateThread(function()
    LoadAnimDict("melee@unarmed@streamed_core")

    while true do
        local sleep = 500

        if CurrentZone and #spawnedZombies > 0 then
            sleep = 150
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)
            local zoneCoords = GetVector3Coords(CurrentZone.coords)
            local now = GetGameTimer()

            for i = #spawnedZombies, 1, -1 do
                local z = spawnedZombies[i]
                local ped = z.ped

                if DoesEntityExist(ped) then
                    if IsEntityDead(ped) then
                        if not z.isDead then
                            z.isDead = true
                            z.deathTime = now
                        else
                            -- Respawn logic after timeout
                            if now - z.deathTime > (Config.Zombies.RespawnTime * 1000) then
                                DeleteEntity(ped)
                                table.remove(spawnedZombies, i)
                            end
                        end
                    else
                        local zCoords = GetEntityCoords(ped)
                        local distToPlayer = #(zCoords - pCoords)
                        local distToZoneCenter = #(zCoords - zoneCoords)

                        -- Check tethering: pull zombie back if it strays too far out of zone
                        if distToZoneCenter > (CurrentZone.radius + Config.Zombies.TetherDistanceMargin) then
                            TaskGoToCoordAnyMeans(ped, zoneCoords.x, zoneCoords.y, zoneCoords.z, 2.0, 0, 0, 786603, 0xbf800000)
                        else
                            -- Target detection & Chase behavior
                            if distToPlayer <= Config.Zombies.TargetDetectDistance and not IsPedInAnyVehicle(playerPed, false) then
                                TaskCombatPed(ped, playerPed, 0, 16)

                                -- Non-blocking attack cooldown handling
                                if distToPlayer <= Config.Zombies.AttackDistance then
                                    if now >= (z.nextAttack or 0) and not IsPedBeingStunned(ped, 0) then
                                        z.nextAttack = now + 1200 -- 1.2s cooldown
                                        ClearPedTasksImmediately(ped)
                                        TaskPlayAnim(ped, "melee@unarmed@streamed_core", "short_0_fight", 8.0, -8.0, 1000, 0, 0, false, false, false)

                                        local baseDmg = (CurrentZone.zombieDamage or Config.Zombies.DefaultDamage)
                                        local mult = z.damageMult or 1.0
                                        local finalDmg = math.floor(baseDmg * mult)

                                        ApplyDamageToPed(playerPed, finalDmg, false)

                                        -- Trigger Player Infection Hit Event
                                        TriggerEvent('zombie_zones:client:addInfectionHit')
                                    end
                                end
                            else
                                -- Wander around inside zone
                                if not GetIsTaskActive(ped, 224) and not GetIsTaskActive(ped, 225) then
                                    local wanderCoord = GetRandomCoordInZone(zoneCoords, CurrentZone.radius)
                                    TaskWanderInArea(ped, wanderCoord.x, wanderCoord.y, wanderCoord.z, 15.0, 3.0, 5.0)
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
