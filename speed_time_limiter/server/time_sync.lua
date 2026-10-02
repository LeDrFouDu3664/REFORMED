-- Synchronisation de l'heure du serveur avec l'heure réelle de la machine hôte

-- Fonction pour obtenir et envoyer l'heure aux clients
local function SyncTime()
    local timeTable = os.date("*t")
    local hours = timeTable.hour
    local minutes = timeTable.min
    local seconds = timeTable.sec

    -- Envoyer l'heure à tous les clients
    TriggerClientEvent('speed_time_limiter:syncTime', -1, hours, minutes, seconds)
end

-- Thread pour synchroniser régulièrement l'heure
Citizen.CreateThread(function()
    while true do
        SyncTime()
        Citizen.Wait(Config.TimeSyncInterval)
    end
end)

-- Synchroniser l'heure lorsqu'un joueur se connecte
RegisterNetEvent('playerJoining')
AddEventHandler('playerJoining', function()
    local src = source
    local timeTable = os.date("*t")
    TriggerClientEvent('speed_time_limiter:syncTime', src, timeTable.hour, timeTable.min, timeTable.sec)
end)
