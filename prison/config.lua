Config = {}

-- Framework Settings
Config.Framework = "auto" -- "esx", "qbcore", or "auto"

-- General Settings
Config.PrisonerJobs = {
    "prisonnier",
}

Config.GuardJobs = {
    "police",
    "garde",
}

Config.EMSJobs = {
    "ambulance",
}

-- Economy
Config.Currency = "money" -- "money", "bank", "black_money"

Config.JobRewards = {
    Faissier = 50,
    Cuisine = 60,
    Nettoyage = 40,
    Logistique = 70,
    Buanderie = 45
}

-- Time Reduction (in minutes per job completed)
Config.JobTimeReduction = 5

-- Schedule (Real-world time)
Config.Schedule = {
    Reveil = "08:00",
    TravailMatin = "09:00",
    RepasMidi = "12:00",
    TempsLibre = "14:00",
    TravailAprem = "16:00",
    RepasSoir = "19:00",
    CouvreFeu = "22:00"
}

-- Locations
Config.Locations = {
    JailSpawn = vector3(1679.0, 2513.0, 45.5),
    ReleaseSpawn = vector3(1850.0, 2600.0, 45.5),
    Jobs = {
        Faissier = vector3(1650.0, 2500.0, 45.0),
        Cuisine = vector3(1660.0, 2520.0, 45.0),
        Nettoyage = vector3(1670.0, 2530.0, 45.0),
        Logistique = vector3(1680.0, 2540.0, 45.0),
        Buanderie = vector3(1690.0, 2550.0, 45.0)
    },
    VendorSpawns = {
        vector3(1640.0, 2510.0, 45.0),
        vector3(1650.0, 2530.0, 45.0),
        vector3(1660.0, 2550.0, 45.0)
    }
}

Config.Peds = {
    VendorModel = "s_m_y_prisoner_01"
}
