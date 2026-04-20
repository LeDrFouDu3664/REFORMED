local isHudHidden = false
local seatbelt = false
local speedLimiter = false
local limiterSpeed = 0

RegisterCommand("edithud", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "toggleDragMode", state = true })
end)

RegisterNUICallback("closeEdit", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "toggleDragMode", state = false })
    cb("ok")
end)

local tickRate = 200

CreateThread(function()
    while true do
        Wait(tickRate)

        if not isHudHidden then
            local ped = PlayerPedId()
            local inVehicle = IsPedInAnyVehicle(ped, false)

            if inVehicle then
                tickRate = 50
            else
                tickRate = 200
            end

            local playerId = GetPlayerServerId(PlayerId())
            local time = GetClockHours() .. ":" .. string.format("%02d", GetClockMinutes())
            local date = "01.01.2025"

            local health = GetEntityHealth(ped) - 100
            if health < 0 then health = 0 end
            if health > 100 then health = 100 end

            local armor = GetPedArmour(ped)
            local hunger = 100
            local thirst = 100

            local speed = 0
            local fuel = 100
            local engineHealth = 1000
            local rpm = 0

            if inVehicle then
                local vehicle = GetVehiclePedIsIn(ped, false)
                speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
                engineHealth = GetVehicleEngineHealth(vehicle)
                rpm = GetVehicleCurrentRpm(vehicle)
            end

            SendNUIMessage({
                action = 'updateHUD',
                id = playerId,
                playerCount = 128,
                time = time,
                date = date,
                money = 5000,
                bank = 15000,
                black = 0,
                health = health,
                armor = armor,
                hunger = hunger,
                thirst = thirst,
                inVehicle = inVehicle,
                speed = speed,
                rpm = rpm,
                engineHealth = engineHealth,
                fuel = fuel,
                seatbelt = seatbelt,
                speedLimiter = speedLimiter
            })
        else
            SendNUIMessage({ action = 'hideHUD' })
            Wait(1000)
        end
    end
end)

RegisterCommand("seatbelt", function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        seatbelt = not seatbelt
    end
end)
RegisterKeyMapping("seatbelt", "Attacher/Detacher ceinture", "keyboard", "B")

RegisterCommand("limiter", function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        speedLimiter = not speedLimiter
        local vehicle = GetVehiclePedIsIn(ped, false)
        if speedLimiter then
            limiterSpeed = GetEntitySpeed(vehicle)
            SetEntityMaxSpeed(vehicle, limiterSpeed)
        else
            SetEntityMaxSpeed(vehicle, 0.0)
        end
    end
end)
RegisterKeyMapping("limiter", "Activer/Desactiver limiteur", "keyboard", "Y")
