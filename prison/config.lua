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
    Buanderie = 45,
    Magasinier = 65,
    Metallier = 80,
    Blanchisseur = 55,
    Menuisier = 75
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
        Buanderie = vector3(1690.0, 2550.0, 45.0),
        Magasinier = vector3(1685.0, 2545.0, 45.0),
        Metallier = vector3(1655.0, 2505.0, 45.0),
        Blanchisseur = vector3(1695.0, 2555.0, 45.0),
        Menuisier = vector3(1665.0, 2515.0, 45.0)
    },
    VendorSpawns = {
        vector3(1640.0, 2510.0, 45.0),
        vector3(1650.0, 2530.0, 45.0),
        vector3(1660.0, 2550.0, 45.0)
    },
    Helpers = {
        { model = "s_m_y_cop_01", coords = vector3(1679.5, 2515.0, 45.5), heading = 180.0, name = "Gardien d'accueil" },
        { model = "s_m_m_prisguard_01", coords = vector3(1675.0, 2520.0, 45.5), heading = 90.0, name = "Chef d'atelier" }
    }
}

Config.Peds = {
    VendorModel = "s_m_y_prisoner_01"
}
