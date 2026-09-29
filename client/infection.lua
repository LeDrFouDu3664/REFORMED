PlayerInfectionLevel = 0
PlayerInfectionStage = 0
IsTransformedZombie = false

local lastCoughTime = 0
local lastDecayTime = 0
local drugEffectEndTime = 0

-- Helper: Load Animation Dictionary
local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Sync infection level from server
RegisterNetEvent('zombie_zones:client:syncInfection', function(level, stage, transformed)
    PlayerInfectionLevel = level or 0
    PlayerInfectionStage = stage or 0
    IsTransformedZombie = transformed or false

    SendNUIMessage({
        type = 'updateInfection',
        level = PlayerInfectionLevel,
        stage = PlayerInfectionStage
    })

    if IsTransformedZombie then
        ApplyZombieTransformation()
    end
end)

-- Item Usage: Zombie Blood Bag (Infection Cure)
RegisterNetEvent('zombie_zones:client:useBloodBag', function()
    if IsTransformedZombie then return end

    local cureAmount = Config.Loot.Items.ZombieBloodBag.cureAmount or 40
    PlayerInfectionLevel = math.max(0, PlayerInfectionLevel - cureAmount)
    UpdateInfectionStage()

    local ped = PlayerPedId()
    LoadAnimDict("mp_suicide")
    TaskPlayAnim(ped, "mp_suicide", "pill", 8.0, -8.0, 2500, 0, 0, false, false, false)

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 128},
        args = {"[Infection]", Config.Language['used_blood_bag']}
    })

    TriggerServerEvent('zombie_zones:server:savePlayerInfection', PlayerInfectionLevel, PlayerInfectionStage, IsTransformedZombie)
end)

-- Item Usage: Zombie Drug / Viral Syringe (Speed & Adrenaline Boost)
RegisterNetEvent('zombie_zones:client:useZombieDrug', function()
    local ped = PlayerPedId()
    local duration = (Config.Loot.Items.ZombieDrug.duration or 30) * 1000
    drugEffectEndTime = GetGameTimer() + duration

    LoadAnimDict("mp_suicide")
    TaskPlayAnim(ped, "mp_suicide", "pill", 8.0, -8.0, 2500, 0, 0, false, false, false)

    TriggerEvent('chat:addMessage', {
        color = {255, 0, 255},
        args = {"[Drogue Virale]", Config.Language['used_drug']}
    })
end)

-- Receive Infection Hit from Zombie Attack
RegisterNetEvent('zombie_zones:client:addInfectionHit', function()
    if not Config.Infection.Enabled or IsTransformedZombie then return end

    if math.random(1, 100) <= Config.Infection.InfectionChancePerHit then
        PlayerInfectionLevel = math.min(100, PlayerInfectionLevel + Config.Infection.InfectionIncreasePerHit)
        UpdateInfectionStage()

        TriggerEvent('chat:addMessage', {
            color = {255, 50, 50},
            args = {"[Infection]", Config.Language['infected_warning']}
        })

        TriggerServerEvent('zombie_zones:server:savePlayerInfection', PlayerInfectionLevel, PlayerInfectionStage, IsTransformedZombie)
    end
end)

-- Update Infection Stage and Trigger Stage Messages
function UpdateInfectionStage()
    local oldStage = PlayerInfectionStage

    if PlayerInfectionLevel >= Config.Infection.FinalStageThreshold then
        PlayerInfectionStage = 3
        TriggerFinalStageConsequence()
    elseif PlayerInfectionLevel >= Config.Infection.Stage3Threshold then
        PlayerInfectionStage = 3
        if oldStage < 3 then
            TriggerEvent('chat:addMessage', { color = {255, 0, 0}, args = {"[Infection]", Config.Language['stage3_msg']} })
        end
    elseif PlayerInfectionLevel >= Config.Infection.Stage2Threshold then
        PlayerInfectionStage = 2
        if oldStage < 2 then
            TriggerEvent('chat:addMessage', { color = {255, 128, 0}, args = {"[Infection]", Config.Language['stage2_msg']} })
        end
    elseif PlayerInfectionLevel >= Config.Infection.Stage1Threshold then
        PlayerInfectionStage = 1
        if oldStage < 1 then
            TriggerEvent('chat:addMessage', { color = {255, 200, 0}, args = {"[Infection]", Config.Language['stage1_msg']} })
        end
    else
        PlayerInfectionStage = 0
    end

    SendNUIMessage({
        type = 'updateInfection',
        level = PlayerInfectionLevel,
        stage = PlayerInfectionStage
    })
end

-- Trigger Final Stage (Transformation or RP Death)
function TriggerFinalStageConsequence()
    if IsTransformedZombie then return end

    if Config.Infection.FinalConsequence == 'zombie_transform' then
        IsTransformedZombie = true
        TriggerEvent('chat:addMessage', {
            color = {200, 0, 0},
            args = {"[TRANSFORMATION]", Config.Language['transformation_msg']}
        })
        ApplyZombieTransformation()
    else
        -- RP Death
        TriggerEvent('chat:addMessage', {
            color = {250, 0, 0},
            args = {"[MORT RP]", Config.Language['rp_death_msg']}
        })
        SetEntityHealth(PlayerPedId(), 0)
    end

    TriggerServerEvent('zombie_zones:server:savePlayerInfection', PlayerInfectionLevel, PlayerInfectionStage, IsTransformedZombie)
end

-- Apply Zombie Transformation (Change Model & Behavior)
function ApplyZombieTransformation()
    local ped = PlayerPedId()
    local modelHash = GetHashKey(Config.Infection.ZombiePedModel or 'u_m_y_zombie_01')

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(10) end

    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)

    local newPed = PlayerPedId()
    SetPedIsDrunk(newPed, true)
    SetAmbientVoiceName(newPed, "ALIENS")
    SetPedAudioSpecialEffectMode(newPed, 2)

    -- Apply zombie drunk walk style
    local walkStyle = 'move_m@drunk@verydrunk'
    RequestAnimSet(walkStyle)
    while not HasAnimSetLoaded(walkStyle) do Wait(10) end
    SetPedMovementClipset(newPed, walkStyle, 1.0)
end

-- Symptom, Drug Effect & Visual Effects Loop
CreateThread(function()
    while true do
        local sleep = 1000
        local now = GetGameTimer()
        local ped = PlayerPedId()

        -- Drug Speed Boost Active
        if now < drugEffectEndTime then
            sleep = 200
            SetAnimRate(ped, Config.Loot.Items.ZombieDrug.speedBoost or 1.5, 0.0, false)
            SetPedMoveRateOverride(ped, Config.Loot.Items.ZombieDrug.speedBoost or 1.5)
            RestorePlayerStamina(PlayerId(), 1.0)
        end

        if Config.Infection.Enabled and PlayerInfectionLevel > 0 and not IsTransformedZombie then
            sleep = 500

            -- 1. Apply Screen Timecycle Effect based on stage
            if PlayerInfectionStage == 2 then
                SetTimecycleModifier(Config.Infection.TimecycleModifiers.Stage2)
                SetTimecycleModifierStrength(0.8)
            elseif PlayerInfectionStage == 3 then
                SetTimecycleModifier(Config.Infection.TimecycleModifiers.Stage3)
                SetTimecycleModifierStrength(1.0)
            else
                ClearTimecycleModifier()
            end

            -- 2. Coughing Symptom Animation & Audio
            local coughDelay = (PlayerInfectionStage == 3 and Config.Infection.CoughInterval.Stage3 or Config.Infection.CoughInterval.Stage2) * 1000
            if PlayerInfectionStage >= 2 and (now - lastCoughTime > coughDelay) then
                lastCoughTime = now
                LoadAnimDict("timetable@gardener@filling_can")
                TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 8.0, -8.0, 2000, 0, 0, false, false, false)

                SendNUIMessage({ type = 'playSound', sound = 'cough', volume = 0.5 })
            end

            -- 3. Health Decay per Stage
            if now - lastDecayTime > 5000 then
                lastDecayTime = now
                local decayHp = 0
                if PlayerInfectionStage == 2 then
                    decayHp = Config.Infection.HealthDecay.Stage2
                elseif PlayerInfectionStage == 3 then
                    decayHp = Config.Infection.HealthDecay.Stage3
                end

                if decayHp > 0 then
                    local currentHp = GetEntityHealth(ped)
                    if currentHp > decayHp then
                        SetEntityHealth(ped, currentHp - decayHp)
                    end
                end
            end
        else
            ClearTimecycleModifier()
        end

        Wait(sleep)
    end
end)
