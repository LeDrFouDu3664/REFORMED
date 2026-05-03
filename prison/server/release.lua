RegisterNetEvent("prison:server:restoreJob")
AddEventHandler("prison:server:restoreJob", function()
    local _source = source
    if GetFramework() == "esx" then
        local xPlayer = ESX.GetPlayerFromId(_source)
        if xPlayer then
            xPlayer.setJob("unemployed", 0)
        end
    end
end)
