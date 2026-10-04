Config = {}

-- =========================================================================
-- LISTE DE VOS MAPPINGS ACTIFS
-- =========================================================================
-- Ajoutez ici le nom des dossiers (ou noms de mappings) que vous avez ajoutés.
-- Le script cherchera automatiquement dans la base de données ci-dessous
-- quels bâtiments, PNJ et sons désactiver.
Config.ActiveMLOs = {
    "PillboxHospital",
    "MissionRowPolice",
    "LTD_Davis",
    "LTD_MirrorPark"
}

-- =========================================================================
-- BASE DE DONNÉES DES BÂTIMENTS GTA V
-- =========================================================================
-- Vous n'avez pas besoin de toucher cette partie normalement.
-- Elle contient les informations pour nettoyer chaque zone de la carte.
Config.Database = {

    ["PillboxHospital"] = {
        iplsToRemove = {
            "rc12b_default", "rc12b_hospitalinterior", "rc12b_hospitalinterior_lod",
            "rc12b_destroyed", "coronertrash", "Coroner_Int_On"
        },
        clearArea = { coords = vector3(340.0, -580.0, 28.0), radius = 150.0 },
        audioEmitters = { "hospital_ambience", "hospital_construction" }
    },

    ["MissionRowPolice"] = {
        iplsToRemove = { "v_57_carmod" },
        clearArea = { coords = vector3(425.0, -980.0, 30.0), radius = 100.0 },
        audioEmitters = {}
    },

    ["LTD_Davis"] = {
        iplsToRemove = { "v_int_49" },
        clearArea = { coords = vector3(-48.0, -1757.0, 29.0), radius = 50.0 },
        audioEmitters = {}
    },

    ["LTD_MirrorPark"] = {
        iplsToRemove = { "v_int_24" },
        clearArea = { coords = vector3(1163.0, -323.0, 69.0), radius = 50.0 },
        audioEmitters = {}
    }
}
