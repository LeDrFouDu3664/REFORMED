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

Config.InventorySystem = 'ox_inventory' -- 'esx' ou 'ox_inventory'

Config.Locations = {
    Armory = vector3(1834.78, 2589.67, 46.01), -- Armurerie des gardes
    Infirmary = vector3(1769.75, 2568.16, 45.72), -- Infirmerie pour les EMS
    PrisonerStash = vector3(1705.50, 2555.30, 45.56), -- Boîte d'effets personnels pour les prisonniers
    Canteen = vector3(1722.50, 2561.30, 45.56), -- Endroit pour prendre à manger
    Gym = vector3(1641.50, 2527.30, 45.56) -- Salle de musculation
}

-- Système d'Évasion
Config.Escape = {
    StartCoords = vector3(1703.10, 2465.20, 45.56), -- Point d'évasion (Ex: grille cassée ou tunnel)
    ExitCoords = vector3(1740.10, 2445.20, 45.56),  -- Point d'arrivée après évasion (De l'autre côté du mur)
    RequiredItem = 'lockpick', -- Objet requis pour s'échapper
    Duration = 15000, -- Durée du crochetage/minage en ms
    PoliceAlert = "ALERTE SÉCURITÉ : UN DÉTENU EST EN TRAIN DE S'ÉCHAPPER DU PÉNITENCIER !"
}

-- Système de Cantine (Nourriture donnée)
Config.CanteenItems = {
    Food = { item = 'bread', count = 1 },
    Drink = { item = 'water', count = 1 }
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
        Reward = { timeReduction = 2, money = 15, msg = "Vous avez réduit votre peine de 2 mois et gagné 15$ en minant." },
        Anim = { dict = "melee@hatchet@streamed_core", name = "plyr_rear_takedown_b" }
    },
    Janitor = {
        Coords = {
            vector3(1710.25, 2560.45, 45.56), -- Couloir principal
            vector3(1720.50, 2565.30, 45.56)  -- Cantine
        },
        Reward = { timeReduction = 1, money = 10, msg = "Vous avez réduit votre peine d'un mois et gagné 10$ en nettoyant." },
        Anim = { dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", name = "machinic_loop_mechandplayer" }
    },
    Laundry = {
        Coords = {
            vector3(1730.00, 2555.00, 45.56),
            vector3(1732.50, 2555.00, 45.56)
        },
        Reward = { timeReduction = 2, money = 12, msg = "Vous avez réduit votre peine de 2 mois et gagné 12$ à la blanchisserie." },
        Anim = { dict = "amb@prop_human_bum_bin@idle_b", name = "idle_d" }
    },
    Kitchen = {
        Coords = {
            vector3(1715.00, 2570.00, 45.56),
            vector3(1717.50, 2570.00, 45.56)
        },
        Reward = { timeReduction = 1, money = 20, msg = "Vous avez réduit votre peine d'un mois et gagné 20$ en cuisinant." },
        Anim = { dict = "anim@heists@prison_heiststation@cop_reactions", name = "cop_b_idle" }
    },
    Workout = {
        Coords = {
            vector3(1640.00, 2530.00, 45.56), -- Cour de la prison (pompes)
            vector3(1642.50, 2530.00, 45.56)
        },
        Reward = { timeReduction = 1, money = 0, msg = "Faire de l'exercice a allégé votre esprit (et votre peine)." },
        Anim = { dict = "amb@world_human_push_ups@male@base", name = "base" }
    }
}

-- PNJs d'aide statiques
Config.GuardNPCs = {
    { model = 's_m_m_prisguard_01', coords = vector4(1832.10, 2587.50, 45.01, 180.0), text = "L'armurerie est derrière moi. Équipez-vous bien !" },
    { model = 's_m_m_prisguard_01', coords = vector4(1853.50, 2599.20, 44.32, 90.0), text = "Bienvenue à Bolingbroke. Faites pas d'histoires." },
    { model = 's_m_m_prisguard_01', coords = vector4(1679.50, 2512.40, 44.56, 120.0), text = "Respectez l'emploi du temps ou c'est l'isolement." }
}

-- Cinématique d'arrivée (Trailer LSPD)
Config.Cutscene = {
    VehicleModel = 'police3',
    DriverModel = 's_m_y_cop_01',
    SpawnCar = vector4(1867.50, 2617.20, 45.50, 180.0), -- Point de spawn de la voiture (Ex: Parking LSPD ou entrée prison)
    DropoffCar = vector4(1845.50, 2585.80, 45.50, 180.0) -- Point où le joueur est déposé (Bureau des gardes)
}

-- Système de Vendeur Illégal (Spawn 1 fois/jour)
-- Tu peux modifier et ajouter autant de points de spawn que tu veux.
Config.BlackMarket = {
    Model = 'g_m_m_chigoon_01',
    Spawns = {
        vector4(1620.50, 2500.20, 44.56, 45.0),
        vector4(1750.30, 2540.60, 44.56, 90.0),
        vector4(1680.10, 2580.80, 44.56, 180.0)
    },
    Items = {
        { item = 'phone', price = 500, label = 'Téléphone Jetable' },
        { item = 'lockpick', price = 250, label = 'Crochet' },
        { item = 'WEAPON_KNIFE', price = 1000, label = 'Surin' }
    }
}

-- Quêtes Illégales
Config.QuestNPC = {
    Model = 'u_m_y_prisoner_01',
    Coords = vector4(1645.00, 2535.00, 44.56, 120.0),
    Text = "Hé, ramène-moi un téléphone du vendeur et je te donnerai un truc intéressant...",
    Requirement = 'phone',
    Reward = 'WEAPON_KNIFE'
}

-- Accueil et Choix de Rôle (Après cinématique)
Config.ReceptionGuard = {
    Model = 's_m_m_prisguard_01',
    Coords = vector4(1855.93, 2601.95, 44.32, 270.0), -- Entrée de la prison (devant le portail)
    Text = "Prends le temps de t'habiller (création de perso). Viens me parler quand t'es prêt pour ton affection."
}

-- Programmation du Chemin du Tutoriel (Guide PNJ)
Config.TutorialPath = {
    Model = 'u_m_y_prisoner_01',
    Nodes = {
        { coords = vector3(1840.00, 2585.00, 45.56), text = "Voici le bureau des gardes. Reste loin si tu veux éviter les coups." },
        { coords = vector3(1770.00, 2570.00, 45.56), text = "Ici c'est l'infirmerie. Pratique quand on se fait planter." },
        { coords = vector3(1720.00, 2565.00, 45.56), text = "La cantine. Mange, bosse, et ferme-la. Tu peux cuistoter pour réduire ta peine." },
        { coords = vector3(1640.00, 2530.00, 45.56), text = "La cour. Un bon endroit pour faire du sport... ou des mauvaises rencontres." }
    }
}
