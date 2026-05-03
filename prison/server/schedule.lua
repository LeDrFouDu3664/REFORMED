local currentPhase = "Reveil"

local function TimeToMinutes(timeStr)
    local h, m = timeStr:match("(%d+):(%d+)")
    return tonumber(h) * 60 + tonumber(m)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute

        local year, month, day, hour, minute, second = GetLocalTime()
        local currentTimeStr = string.format("%02d:%02d", hour, minute)
        local currentMins = TimeToMinutes(currentTimeStr)

        local newPhase = "CouvreFeu"
        local phases = {
            {name="Reveil", time=Config.Schedule.Reveil},
            {name="TravailMatin", time=Config.Schedule.TravailMatin},
            {name="RepasMidi", time=Config.Schedule.RepasMidi},
            {name="TempsLibre", time=Config.Schedule.TempsLibre},
            {name="TravailAprem", time=Config.Schedule.TravailAprem},
            {name="RepasSoir", time=Config.Schedule.RepasSoir},
            {name="CouvreFeu", time=Config.Schedule.CouvreFeu}
        }

        for i, phase in ipairs(phases) do
            if currentMins >= TimeToMinutes(phase.time) then
                if i == #phases or currentMins < TimeToMinutes(phases[i+1].time) then
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
