local phasesOrder = {
    "Reveil",
    "Douches",
    "PetitDejeuner",
    "TravailMatin",
    "PromenadeMatin",
    "RepasMidi",
    "Inspection",
    "TravailAprem",
    "TempsLibre",
    "RepasSoir",
    "Appel",
    "CouvreFeu",
    "RondeDeNuit",
    "Dortoir"
}

local currentIndex = 1
local currentPhase = phasesOrder[currentIndex]

Citizen.CreateThread(function()
    while true do
        -- Fast-paced schedule: advance to the next phase every 5 minutes (300,000 ms)
        Citizen.Wait(300000)

        currentIndex = currentIndex + 1
        if currentIndex > #phasesOrder then
            currentIndex = 1
        end

        currentPhase = phasesOrder[currentIndex]

        TriggerClientEvent("prison:client:scheduleUpdate", -1, currentPhase)
        print("[Prison] L'emploi du temps a changé pour: " .. currentPhase)
    end
end)

RegisterNetEvent("prison:server:getSchedule")
AddEventHandler("prison:server:getSchedule", function()
    TriggerClientEvent("prison:client:scheduleUpdate", source, currentPhase)
end)
