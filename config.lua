Config = {}

-- Framework options: 'esx', 'qbcore', 'standalone'
Config.Framework = 'esx'

-- Database Persistence: 'oxmysql', 'json'
Config.DatabaseType = 'oxmysql'

-- Command name for Admin Panel
Config.AdminCommand = 'zombieadmin'

-- Admin permissions allowed to open admin panel (ESX / QBCore groups, or ACE permissions)
Config.AdminGroups = {
    ['superadmin'] = true,
    ['admin'] = true,
    ['god'] = true
}

-- Default Zombie Settings
Config.Zombies = {
    Models = {
        'u_m_y_zombie_01',
        'a_m_m_hillbilly_01',
        'a_m_m_salton_01',
        'a_m_y_skater_01',
        'g_m_y_famdnf_01'
    },
    WalkStyles = {
        'move_m@drunk@verydrunk',
        'move_m@injured',
        'move_m@gangster@varriosec'
    },
    DefaultHealth = 150,
    DefaultSpeed = 1.2, -- Speed modifier
    DefaultDamage = 15, -- Damage per attack
    DefaultMaxCount = 20, -- Default max zombies per active zone
    RespawnTime = 15, -- Seconds before dead zombie respawns in zone
    AttackDistance = 1.8,
    TargetDetectDistance = 35.0,
    TetherDistanceMargin = 10.0 -- Margin allowed outside zone boundary before zombie is pulled back
}

-- Zombie Loot & Crafting Configuration
Config.Loot = {
    Enabled = true,
    LootDistance = 2.0,
    Items = {
        ZombieBloodBag = {
            name = 'zombie_blood_bag',
            label = 'Poche de sang de zombie',
            dropChance = 40, -- 40% chance on looting
            cureAmount = 40  -- Reduces infection level by 40%
        },
        ZombieDrug = {
            name = 'zombie_drug',
            label = 'Seringue Virale / Drogue',
            dropChance = 25, -- 25% chance on looting
            speedBoost = 1.5, -- Speed multiplier boost
            duration = 30    -- Duration in seconds
        }
    },
    -- Recipe for Crafting Zombie Drug (Poche de sang + Weed + Pochon vide)
    Crafting = {
        Enabled = true,
        CraftTime = 5000, -- 5 seconds crafting time
        Recipe = {
            { name = 'zombie_blood_bag', count = 1, label = 'Poche de sang de zombie' },
            { name = 'weed', count = 1, label = 'Feuille de Weed' },
            { name = 'pooch', count = 1, label = 'Pochon vide' }
        },
        Result = { name = 'zombie_drug', count = 1 }
    }
}

-- Player Infection System Configuration
Config.Infection = {
    Enabled = true,
    InfectionChancePerHit = 60, -- 60% chance to contract infection on zombie melee hit
    InfectionIncreasePerHit = 35, -- Percentage added per hit (Reach 100% after ~3 hits / 3 stages)

    -- Stage Thresholds (%)
    Stage1Threshold = 1,   -- Stade 1 : Contamination débutante
    Stage2Threshold = 35,  -- Stade 2 : Contamination modérée (Symptômes visuels & toux)
    Stage3Threshold = 70,  -- Stade 3 : Contamination critique (Altération vision, perte de santé)
    FinalStageThreshold = 100, -- Stade Final : Transformation ou Mort RP

    -- Final Consequence Option: 'zombie_transform' or 'rp_death'
    FinalConsequence = 'zombie_transform',

    -- Transformation Zombie Model
    ZombiePedModel = 'u_m_y_zombie_01',

    -- Health Decay Rate per Stage (HP lost every 5 seconds)
    HealthDecay = {
        Stage1 = 0,
        Stage2 = 1,
        Stage3 = 3
    },

    -- Screen Post-Processing Effects
    TimecycleModifiers = {
        Stage1 = nil,
        Stage2 = 'spectator1',
        Stage3 = 'p_deluxo_interior'
    },

    -- Coughing Animation Interval (seconds)
    CoughInterval = {
        Stage2 = 30,
        Stage3 = 15
    }
}

-- Props / Barricades Placement Configuration
Config.Props = {
    Enabled = true,
    PlaceableModels = {
        { label = "Barrière de Chantier", model = "prop_barrier_work05" },
        { label = "Sac de Sable", model = "prop_sandbag_01" },
        { label = "Hérisson Tchèque Anti-Véhicule", model = "prop_hedgehog" },
        { label = "Barrière en Bois", model = "prop_fncwood_16a" },
        { label = "Panneau Danger Biohazard", model = "prop_sign_road_01a" }
    }
}

-- Default Environment & Ambiance Settings
Config.Ambiance = {
    DefaultWeather = 'HALLOWEEN',
    DefaultTime = { hour = 0, minute = 0 },
    TimecycleModifier = 'spectator5', -- Post-apocalyptic atmospheric overlay
    FogDensity = 0.3,
    EnableSoundEffects = true,
    SoundInterval = { min = 20, max = 45 } -- Random atmospheric sound interval in seconds
}

-- Halloween Event Overrides
Config.Halloween = {
    Weather = 'HALLOWEEN',
    TimecycleModifier = 'm_blackout',
    Time = { hour = 0, minute = 0 },
    ZombieCountMultiplier = 1.5,
    ZombieDamageMultiplier = 1.3,
    ZombieHealthMultiplier = 1.4,
    ZombieSpeedMultiplier = 1.2
}

-- Preset Abandoned Vehicle Models
Config.VehicleModels = {
    'rubble',
    'surfer',
    'emperor2',
    'tornado3',
    'voodoo2',
    'rebel2',
    'blazer',
    'bodhi2'
}

-- Default Initial Zones
Config.DefaultZones = {
    {
        id = "zone_sandy_shores",
        name = "Sandy Shores Infecté",
        coords = vector3(1850.0, 3680.0, 34.0),
        radius = 200.0,
        active = true,
        zombieMax = 25,
        zombieHealth = 150,
        zombieSpeed = 1.1,
        zombieDamage = 15,
        weather = "HALLOWEEN",
        halloween = false,
        blip = {
            sprite = 436,
            color = 1,
            scale = 0.9,
            label = "Zone Infectée - Sandy Shores"
        }
    }
}

-- Localization (100% French)
Config.Language = {
    ['admin_panel_title'] = "Gestionnaire de Zones d'Infection Zombie",
    ['zone_entered'] = "ATTENTION : Vous entrez dans une zone d'infection zombie !",
    ['zone_exited'] = "Vous êtes sorti de la zone d'infection.",
    ['no_permission'] = "Vous n'avez pas la permission d'accéder à ce menu.",
    ['zone_created'] = "Zone d'infection créée avec succès.",
    ['zone_updated'] = "Zone d'infection mise à jour.",
    ['zone_deleted'] = "Zone d'infection supprimée.",
    ['vehicle_placed'] = "Véhicule abandonné placé avec succès.",
    ['vehicle_deleted'] = "Véhicule abandonné supprimé.",
    ['prop_placed'] = "Prop/barricade placé(e) avec succès.",
    ['prop_deleted'] = "Prop/barricade supprimé(e).",
    ['halloween_enabled'] = "Événement Nuit d'Halloween ACTIVÉ dans les zones d'infection.",
    ['halloween_disabled'] = "Événement Nuit d'Halloween DÉSACTIVÉ.",
    ['infected_warning'] = "Vous avez été griffré et contaminé par un zombie ! Niveau d'infection en hausse.",
    ['stage1_msg'] = "Stade 1 : Vous ressentez les premiers frissons de la contamination...",
    ['stage2_msg'] = "Stade 2 : L'infection se propage. Vous toussez et votre vision se trouble.",
    ['stage3_msg'] = "Stade 3 CRITIQUE : L'infection consomme votre corps !",
    ['transformation_msg'] = "TRANSFORMATION : L'infection a pris le contrôle total de votre corps ! Vous êtes devenu un zombie.",
    ['rp_death_msg'] = "MORT RP : L'infection vous a tué.",
    ['loot_prompt'] = "Appuyez sur ~INPUT_CONTEXT~ pour fouiller le zombie.",
    ['already_looted'] = "Ce zombie a déjà été fouillé.",
    ['loot_success_blood'] = "Vous avez trouvé une Poche de sang de zombie !",
    ['loot_success_drug'] = "Vous avez trouvé une Seringue Virale / Drogue !",
    ['loot_nothing'] = "Vous n'avez rien trouvé d'intéressant sur ce zombie.",
    ['used_blood_bag'] = "Vous avez injecté une poche de sang : votre niveau d'infection diminue.",
    ['used_drug'] = "Vous avez consommé la drogue virale : vous ressentez une montée d'adrénaline !",
    ['crafting_start'] = "Fabrication de la drogue virale en cours...",
    ['crafting_success'] = "Fabrication réussie ! Vous avez créé une Seringue Virale / Drogue.",
    ['crafting_missing'] = "Ingrédients manquants ! Il vous faut 1 Poche de sang de zombie, 1 Weed et 1 Pochon vide."
}
