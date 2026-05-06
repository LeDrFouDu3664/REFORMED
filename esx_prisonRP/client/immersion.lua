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
            -- Clear area of cops inside prison
            ClearAreaOfCops(pos.x, pos.y, pos.z, prisonRadius, 0)
        else
            isInsidePrison = false
        end

        if Config.Settings.DisableWantedLevel then
            ClearPlayerWantedLevel(PlayerId())
            SetMaxWantedLevel(0)
        end

        -- Global Time Sync (PC Time)
        local year, month, day, hour, minute, second = GetLocalTime()
        NetworkOverrideClockTime(hour, minute, second)
    end
end)

-- Global CPed loop to make ALL NPCs map-wide non-aggressive
-- Global CPed and Weather loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        -- Global Weather Sync (Sunny/Clear)
        SetWeatherTypePersist("CLEAR")
        SetWeatherTypeNowPersist("CLEAR")
        SetWeatherTypeNow("CLEAR")
        SetOverrideWeather("CLEAR")

        -- Make ALL NPCs map-wide non-aggressive
        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if not IsPedAPlayer(ped) then
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedFleeAttributes(ped, 0, 0)
                SetPedCombatAttributes(ped, 17, 0)
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
            end
        end
    end
end)
