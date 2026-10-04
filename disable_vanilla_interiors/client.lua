Citizen.CreateThread(function()
    print("^2[INFO] Nettoyage des zones pour MLOs initialisé.^0")

    for mloName, data in pairs(Config.CustomMLOs) do

        -- 1. Désactiver les IPLs
        if data.iplsToRemove then
            for _, ipl in ipairs(data.iplsToRemove) do
                RemoveIpl(ipl)
            end
        end

        -- 2. Désactiver les PNJ, Scénarios (travaux) et Véhicules
        if data.clearArea and data.clearArea.coords and data.clearArea.radius then
            local p = data.clearArea.coords
            local r = data.clearArea.radius

            -- Bloquer les scénarios (ouvriers, gens qui fument, etc.)
            AddScenarioBlockingArea(p.x - r, p.y - r, p.z - r, p.x + r, p.y + r, p.z + r, false, true, true, true)

            -- Bloquer la création des PNJ
            SetPedNonCreationArea(p.x - r, p.y - r, p.z - r, p.x + r, p.y + r, p.z + r)

            -- Optionnel: Bloquer la création des véhicules ambiants
            SetAllVehicleGeneratorsActiveInArea(p.x - r, p.y - r, p.z - r, p.x + r, p.y + r, p.z + r, false, false)
            RemoveVehiclesFromGeneratorsInArea(p.x - r, p.y - r, p.z - r, p.x + r, p.y + r, p.z + r)
        end

        -- 3. Désactiver les sons d'ambiance spécifiques (si connus)
        if data.audioEmitters then
            for _, emitterName in ipairs(data.audioEmitters) do
                SetStaticEmitterEnabled(emitterName, false)
            end
        end
    end
end)

-- Boucle continue pour supprimer les PNJ qui auraient pu spawner malgré tout (Optionnel mais efficace)
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for mloName, data in pairs(Config.CustomMLOs) do
            if data.clearArea and data.clearArea.coords and data.clearArea.radius then
                local p = data.clearArea.coords
                local r = data.clearArea.radius

                -- Si le joueur est proche de la zone, nettoyer activement
                if #(playerCoords - p) < (r + 50.0) then
                    ClearAreaOfPeds(p.x, p.y, p.z, r, 1)
                    -- ClearAreaOfVehicles(p.x, p.y, p.z, r, false, false, false, false, false) -- Optionnel
                end
            end
        end
    end
end)
