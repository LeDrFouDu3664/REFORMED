Config = {}

-- Framework options: 'esx', 'qbcore', 'standalone'
Config.Framework = 'esx'

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
    ['halloween_enabled'] = "Événement Nuit d'Halloween ACTIVÉ dans les zones d'infection.",
    ['halloween_disabled'] = "Événement Nuit d'Halloween DÉSACTIVÉ."
}
