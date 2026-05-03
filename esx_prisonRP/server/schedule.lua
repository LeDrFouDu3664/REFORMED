local currentPhase = "Reveil"

local function TimeToMinutes(timeStr)
    local h, m = timeStr:match("(%d+):(%d+)")
    return tonumber(h) * 60 + tonumber(m)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute

        local time = os.date("*t")
        local currentTimeStr = string.format("%02d:%02d", time.hour, time.min)
        local currentMins = TimeToMinutes(currentTimeStr)

        local phases = {}
        for name, time in pairs(Config.Schedule) do
            table.insert(phases, {name = name, timeStr = time, mins = TimeToMinutes(time)})
        end

        -- Sort phases by time (minutes from 00:00)
        table.sort(phases, function(a, b) return a.mins < b.mins end)

        local newPhase = phases[#phases].name -- Default to the last phase of the previous day if we are before the first event

        for i, phase in ipairs(phases) do
            local nextPhase = phases[i+1]

            if nextPhase then
                if currentMins >= phase.mins and currentMins < nextPhase.mins then
                    newPhase = phase.name
                    break
                end
            else
                -- We are at or past the last event of the day
                if currentMins >= phase.mins then
                    newPhase = phase.name
                    break
                end
            end
        end

        if newPhase ~= currentPhase then
            currentPhase = newPhase
            TriggerClientEvent("prison:client:scheduleUpdate", -1, currentPhase)
            print("[Prison] L'emploi du temps a changé pour: " .. currentPhase)
        end
    end
end)

RegisterNetEvent("prison:server:getSchedule")
AddEventHandler("prison:server:getSchedule", function()
    TriggerClientEvent("prison:client:scheduleUpdate", source, currentPhase)
end)
