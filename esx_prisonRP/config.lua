Config = {}

-- Bolingbroke Penitentiary
Config.PrisonCoords = vector3(1677.233, 2509.694, 45.565)
Config.PrisonRadius = 150.0 -- Rayon avant que le joueur soit téléporté s'il s'échappe
Config.ReleaseCoords = vector3(1855.93, 2601.95, 45.32) -- Sortie de prison

Config.Jobs = {
    Police = 'police',
    Garde = 'garde',
    EMS = 'ambulance'
}

Config.Locations = {
    Armory = vector3(1834.78, 2589.67, 46.01), -- Armurerie des gardes
    Infirmary = vector3(1769.75, 2568.16, 45.72), -- Infirmerie pour les EMS
}
