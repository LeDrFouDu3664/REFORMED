local isInsidePrison = false
local wasInsidePrison = false
local prisonCenter = vector3(1679.0, 2513.0, 45.5)
local prisonRadius = 150.0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - prisonCenter)

        if dist < prisonRadius then
            isInsidePrison = true

            -- Clear area of cops
            ClearAreaOfCops(pos.x, pos.y, pos.z, prisonRadius, 0)

            -- Keep time synced with PC time periodically
            local year, month, day, hour, minute, second = GetLocalTime()
            NetworkOverrideClockTime(hour, minute, second)
        else
            isInsidePrison = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if isInsidePrison then
            local peds = GetGamePool('CPed')
            for _, ped in ipairs(peds) do
                if not IsPedAPlayer(ped) then
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedFleeAttributes(ped, 0, 0)
                    SetPedCombatAttributes(ped, 17, 0) -- 17 is AlwaysFight, set to 0 (false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isInsidePrison then
            wasInsidePrison = true
            -- Hide radar when on foot inside prison
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                DisplayRadar(false)
            else
                DisplayRadar(true)
            end

            -- Set Weather to Clear/Sunny
            SetWeatherTypePersist("CLEAR")
            SetWeatherTypeNowPersist("CLEAR")
            SetWeatherTypeNow("CLEAR")
            SetOverrideWeather("CLEAR")

            -- Disable external Peds/Vehicles to increase immersion in the prison area
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)

        else
            if wasInsidePrison then
                wasInsidePrison = false
                -- Restore radar exactly once when leaving prison
                DisplayRadar(true)
                ClearOverrideWeather()
            end
            Citizen.Wait(1000) -- Sleep when outside
        end
    end
end)
