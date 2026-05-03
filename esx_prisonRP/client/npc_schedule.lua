local activeNPCs = {}
local currentSchedulePhase = "Reveil"

RegisterNetEvent("prison:client:scheduleUpdate")
AddEventHandler("prison:client:scheduleUpdate", function(phase)
    currentSchedulePhase = phase

    if Config.Settings.EnableNPCSchedule then
        UpdateNPCDestinations()
    end
end)

function SpawnScheduleNPCs()
    local models = Config.Peds.PrisonerModels
    local startPoint = Config.Locations.SchedulePoints.Dortoir

    for i = 1, 5 do
        local model = GetHashKey(models[math.random(1, #models)])
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(10) end

        local ped = CreatePed(4, model, startPoint.x + math.random(-2, 2), startPoint.y + math.random(-2, 2), startPoint.z - 1.0, 0.0, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetPedCombatAttributes(ped, 17, 0)
        SetBlockingOfNonTemporaryEvents(ped, true)

        table.insert(activeNPCs, ped)
    end
end

function UpdateNPCDestinations()
    local targetCoord = Config.Locations.SchedulePoints.Cour -- default

    if currentSchedulePhase == "Dortoir" or currentSchedulePhase == "CouvreFeu" or currentSchedulePhase == "Reveil" or currentSchedulePhase == "RondeDeNuit" then
        targetCoord = Config.Locations.SchedulePoints.Dortoir
    elseif currentSchedulePhase == "Douches" then
        targetCoord = Config.Locations.SchedulePoints.Douche
    elseif currentSchedulePhase == "PetitDejeuner" or currentSchedulePhase == "RepasMidi" or currentSchedulePhase == "RepasSoir" then
        targetCoord = Config.Locations.SchedulePoints.Cantine
    elseif currentSchedulePhase == "TravailMatin" or currentSchedulePhase == "TravailAprem" then
        targetCoord = Config.Locations.SchedulePoints.Atelier
    end

    for _, ped in ipairs(activeNPCs) do
        if DoesEntityExist(ped) then
            TaskGoStraightToCoord(ped, targetCoord.x + math.random(-3, 3), targetCoord.y + math.random(-3, 3), targetCoord.z, 1.0, -1, 0.0, 0.0)
        end
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    if Config.Settings.EnableNPCSchedule then
        SpawnScheduleNPCs()
        UpdateNPCDestinations()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for _, ped in ipairs(activeNPCs) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
