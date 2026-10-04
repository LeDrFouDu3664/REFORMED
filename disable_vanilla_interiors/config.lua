Config = {}

-- Liste de vos MLOs et des modifications associées
Config.CustomMLOs = {
    -- ============================================
    -- Hôpital Pillbox Hill (Chantier)
    -- ============================================
    ["PillboxHospital"] = {
        -- IPLs par défaut à retirer
        iplsToRemove = {
            "rc12b_default",
            "rc12b_hospitalinterior",
            "rc12b_hospitalinterior_lod",
            "rc12b_destroyed",
            "coronertrash",
            "Coroner_Int_On"
        },
        -- Zone où désactiver les PNJ, les ouvriers (scénarios) et les véhicules
        clearArea = {
            coords = vector3(340.0, -580.0, 28.0),
            radius = 150.0
        },
        -- Émetteurs audio à désactiver (ex: bruits de chantier, bruits d'ambiance)
        audioEmitters = {
            "hospital_ambience",
            "hospital_construction"
        }
    },

    -- ============================================
    -- Commissariat Mission Row
    -- ============================================
    ["MissionRowPolice"] = {
        iplsToRemove = {
            "v_57_carmod"
        },
        clearArea = {
            coords = vector3(425.0, -980.0, 30.0),
            radius = 100.0
        },
        audioEmitters = {}
    },

    -- ============================================
    -- Exemples LTD
    -- ============================================
    ["LTD_Davis"] = {
        iplsToRemove = {
            "v_int_49"
        },
        clearArea = {
            coords = vector3(-48.0, -1757.0, 29.0),
            radius = 50.0
        },
        audioEmitters = {}
    },
    ["LTD_MirrorPark"] = {
        iplsToRemove = {
            "v_int_24"
        },
        clearArea = {
            coords = vector3(1163.0, -323.0, 69.0),
            radius = 50.0
        },
        audioEmitters = {}
    }
}
