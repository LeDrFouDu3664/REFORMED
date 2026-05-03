RegisterNetEvent("prison:server:restoreJob")
AddEventHandler("prison:server:restoreJob", function()
    local _source = source
    if GetFramework() == "esx" then
        local xPlayer = ESX.GetPlayerFromId(_source)
        if xPlayer then
            -- Only reset to unemployed if they are currently holding a prisoner job
            local isPrisoner = false
            for _, pJob in ipairs(Config.PrisonerJobs) do
                if xPlayer.job.name == pJob then
                    isPrisoner = true
                    break
                end
            end
            if isPrisoner then
                xPlayer.setJob("unemployed", 0)
            end
        end
    end
end)
