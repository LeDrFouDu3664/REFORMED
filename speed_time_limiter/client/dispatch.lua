-- Désactiver les services de police (dispatch) et les étoiles de recherche de base de GTA

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Désactiver les étoiles de recherche pour le joueur
        if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end

        -- Empêcher le joueur d'avoir des étoiles
        SetMaxWantedLevel(0)
    end
end)

Citizen.CreateThread(function()
    -- Désactiver les appels de dispatch pour différents services (police, pompiers, ambulance, etc.)
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
end)
