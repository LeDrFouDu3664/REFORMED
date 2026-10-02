Config = {}

-- Les vitesses sont en km/h
-- Conversion interne en m/s dans le script client : vitesse_kmh / 3.6

-- Limites par défaut selon la classe du véhicule
-- Classes: 0: Compacts, 1: Sedans, 2: SUVs, 3: Coupes, 4: Muscle, 5: Sports Classics, 6: Sports, 7: Super, 8: Motorcycles, 9: Off-road, 10: Industrial, 11: Utility, 12: Vans, 13: Cycles, 14: Boats, 15: Helicopters, 16: Planes, 17: Service, 18: Emergency, 19: Military, 20: Commercial, 21: Trains
Config.ClassLimits = {
    [0] = 150.0, -- Compacts
    [1] = 180.0, -- Sedans
    [2] = 170.0, -- SUVs
    [3] = 200.0, -- Coupes
    [4] = 220.0, -- Muscle
    [5] = 230.0, -- Sports Classics
    [6] = 250.0, -- Sports
    [7] = 300.0, -- Super
    [8] = 250.0, -- Motorcycles
    [9] = 160.0, -- Off-road
    [10] = 120.0, -- Industrial
    [11] = 120.0, -- Utility
    [12] = 140.0, -- Vans
    [13] = 50.0,  -- Cycles
    [14] = 150.0, -- Boats
    [15] = 300.0, -- Helicopters
    [16] = 400.0, -- Planes
    [17] = 150.0, -- Service
    [18] = 220.0, -- Emergency (Police, EMS)
    [19] = 180.0, -- Military
    [20] = 130.0, -- Commercial
    [21] = 150.0  -- Trains
}

-- Limites spécifiques par modèle de véhicule (codes d'apparition / model name)
-- Ces limites ont la priorité sur les limites de classe.
-- Police vehicles included explicitely.
Config.ModelLimits = {
    ["police"] = 210.0,
    ["police2"] = 210.0,
    ["police3"] = 220.0,
    ["police4"] = 210.0,
    ["policeb"] = 230.0,
    ["fbi"] = 220.0,
    ["fbi2"] = 220.0,
    ["sheriff"] = 210.0,
    ["sheriff2"] = 210.0,
    ["pranger"] = 200.0,
    ["riot"] = 150.0,
    ["pbus"] = 130.0,
    ["ambulance"] = 180.0,
    ["firetruk"] = 150.0,
    ["bfinjection"] = 140.0,
    ["panto"] = 120.0
}

-- Fréquence de mise à jour du temps en millisecondes (synchronisation serveur -> client)
Config.TimeSyncInterval = 60000 -- 1 minute
