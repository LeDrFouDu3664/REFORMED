-- Recevoir l'heure réelle du serveur
RegisterNetEvent('speed_time_limiter:syncTime')
AddEventHandler('speed_time_limiter:syncTime', function(hours, minutes, seconds)
    NetworkOverrideClockTime(hours, minutes, seconds)
end)

-- S'assurer que le temps s'écoule à la même vitesse que la réalité (1 minute jeu = 1 minute réelle)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Exécuter moins fréquemment, SetMillisecondsPerGameMinute n'a pas besoin d'être appelé chaque frame
        -- Empêche le jeu de changer l'heure tout seul trop vite
        -- 60000 ms = 1 minute réelle = 1 minute en jeu
        SetMillisecondsPerGameMinute(60000)
    end
end)

-- Appeler la fonction une première fois au démarrage
Citizen.CreateThread(function()
    SetMillisecondsPerGameMinute(60000)
end)
