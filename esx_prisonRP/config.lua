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

-- Emploi du temps des prisonniers (Heures in-game 0-23)
Config.Schedule = {
    [7]  = "Réveil et appel matinal dans la cour.",
    [8]  = "Petit-déjeuner à la cantine.",
    [9]  = "Début des travaux d'intérêt général (Mine, Nettoyage).",
    [12] = "Pause déjeuner à la cantine.",
    [13] = "Reprise des travaux ou temps libre (Sport, Bibliothèque).",
    [16] = "Temps libre / Parloir / Promenade dans la cour.",
    [18] = "Dîner à la cantine.",
    [20] = "Appel du soir et retour en cellule.",
    [22] = "Extinction des feux."
}

-- Tâches des prisonniers
Config.PrisonerJobs = {
    Mining = {
        Coords = {
            vector3(1697.55, 2548.88, 45.56),
            vector3(1701.32, 2552.14, 45.56)
        },
        Reward = { timeReduction = 2, msg = "Vous avez réduit votre peine de 2 mois en minant." },
        Anim = { dict = "melee@hatchet@streamed_core", name = "plyr_rear_takedown_b" }
    },
    Janitor = {
        Coords = {
            vector3(1710.25, 2560.45, 45.56), -- Couloir principal
            vector3(1720.50, 2565.30, 45.56)  -- Cantine
        },
        Reward = { timeReduction = 1, msg = "Vous avez réduit votre peine d'un mois en nettoyant." },
        Anim = { dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", name = "machinic_loop_mechandplayer" }
    }
}
