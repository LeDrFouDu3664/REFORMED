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

            if Config.Settings.DisableWantedLevel then
                ClearPlayerWantedLevel(PlayerId())
                SetMaxWantedLevel(0)
            end
        else
            isInsidePrison = false
            if Config.Settings.DisableWantedLevel then
                SetMaxWantedLevel(5)
            end
        end
    end
end)

-- Removed global CPed loop. NPC passiveness is handled at creation
-- for script-spawned NPCs (helpers, scheduled NPCs, vendors)
-- and `ClearAreaOfCops` prevents aggressive cop spawns.

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
                NetworkClearClockTimeOverride()
            end
            Citizen.Wait(1000) -- Sleep when outside
        end
    end
end)
