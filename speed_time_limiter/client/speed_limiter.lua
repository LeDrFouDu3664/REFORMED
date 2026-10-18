Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Vérification chaque seconde (suffisant pour définir la vitesse max de l'entité)

        local ped = PlayerPedId()

        -- Vérifier si le joueur est dans un véhicule
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            -- Vérifier si le joueur est le conducteur
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                local model = GetEntityModel(vehicle)
                local class = GetVehicleClass(vehicle)

                local maxSpeedKmh = nil

                -- Vérifier d'abord les limites spécifiques au modèle (convertir le nom en hash si besoin ou inversement)
                -- GetEntityModel retourne un hash. Pour comparer avec les clés textes de Config.ModelLimits, on peut iterer
                -- ou on peut stocker les clés sous forme de hash dans une nouvelle table
                local foundModelLimit = false
                for modelName, limit in pairs(Config.ModelLimits) do
                    if GetHashKey(modelName) == model then
                        maxSpeedKmh = limit
                        foundModelLimit = true
                        break
                    end
                end

                -- Sinon, utiliser la limite de classe
                if not foundModelLimit and Config.ClassLimits[class] then
                    maxSpeedKmh = Config.ClassLimits[class]
                end

                -- Appliquer la limite de vitesse
                if maxSpeedKmh then
                    -- Convertir km/h en m/s (GTA utilise les m/s pour SetEntityMaxSpeed)
                    local maxSpeedMs = maxSpeedKmh / 3.6
                    SetEntityMaxSpeed(vehicle, maxSpeedMs)
                end
            end
        else
            Citizen.Wait(2000) -- Attendre plus longtemps si le joueur n'est pas dans un véhicule
        end
    end
end)
