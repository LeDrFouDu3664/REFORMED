if GetFramework() ~= "qbcore" then return end

QBCore = exports['qb-core']:GetCoreObject()

function GetPlayerJob()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData or not PlayerData.job then return nil end
    return PlayerData.job.name
end

function ShowNotification(msg)
    QBCore.Functions.Notify(msg)
end
