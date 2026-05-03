if GetFramework() ~= "esx" then return end

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

function GetPlayerJob()
    if not ESX or not ESX.GetPlayerData() or not ESX.GetPlayerData().job then return nil end
    return ESX.GetPlayerData().job.name
end

function ShowNotification(msg)
    ESX.ShowNotification(msg)
end
