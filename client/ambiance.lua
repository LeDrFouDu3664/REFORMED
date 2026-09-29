local inZoneAmbiance = false

-- Environmental Weather & Timecycle Manager Loop
CreateThread(function()
    while true do
        local sleep = 500

        if CurrentZone then
            sleep = 0
            inZoneAmbiance = true

            local weather = (GlobalHalloween or CurrentZone.halloween) and Config.Halloween.Weather or (CurrentZone.weather or Config.Ambiance.DefaultWeather)
            local modifier = (GlobalHalloween or CurrentZone.halloween) and Config.Halloween.TimecycleModifier or Config.Ambiance.TimecycleModifier

            -- Override Weather
            SetWeatherTypePersist(weather)
            SetWeatherTypeNowPersist(weather)
            SetWeatherTypeNow(weather)
            SetOverrideWeather(weather)

            -- Override Darkness / Time
            local timeSetting = (GlobalHalloween or CurrentZone.halloween) and Config.Halloween.Time or Config.Ambiance.DefaultTime
            NetworkOverrideClockTime(timeSetting.hour, timeSetting.minute, 0)

            -- Set Atmospheric Post-processing timecycle modifier
            if modifier and modifier ~= "" then
                SetTimecycleModifier(modifier)
                SetTimecycleModifierStrength(1.0)
            end

            -- Additional Halloween visual effect
            if GlobalHalloween or CurrentZone.halloween then
                SetArtificialLightsState(true) -- Blackout / streetlights off
            else
                SetArtificialLightsState(false)
            end

        elseif inZoneAmbiance then
            inZoneAmbiance = false
            -- Reset weather & timecycle on exit
            ClearOverrideWeather()
            ClearTimecycleModifier()
            SetArtificialLightsState(false)
            NetworkClearClockTimeOverride()
        end

        Wait(sleep)
    end
end)

-- Random Ambient Audio Effects inside Infection Zone
CreateThread(function()
    while true do
        local sleep = 5000

        if CurrentZone and Config.Ambiance.EnableSoundEffects then
            local delay = math.random(Config.Ambiance.SoundInterval.min, Config.Ambiance.SoundInterval.max) * 1000
            Wait(delay)

            if CurrentZone then
                -- Trigger NUI Audio clip
                local soundTypes = { 'scream', 'groan', 'explosion', 'wind' }
                local chosenSound = soundTypes[math.random(#soundTypes)]

                SendNUIMessage({
                    type = 'playSound',
                    sound = chosenSound,
                    volume = 0.4
                })
            end
        else
            Wait(sleep)
        end
    end
end)
