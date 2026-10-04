Citizen.CreateThread(function()
    local iplsToRemove = {
        -- ==========================================
        -- Hôpitaux (Pillbox, Mt Zonah, Sandy Shores)
        -- ==========================================
        "rc12b_default",
        "rc12b_hospitalinterior",
        "rc12b_hospitalinterior_lod",
        "rc12b_destroyed",
        "coronertrash",
        "Coroner_Int_On",

        -- ==========================================
        -- Commissariats (Mission Row, Paleto, etc.)
        -- ==========================================
        "v_57_carmod",

        -- ==========================================
        -- Magasins (LTD, 24/7, Rob's Liquor)
        -- ==========================================
        "v_int_24",
        "v_int_49",

        -- ==========================================
        -- Autres bâtiments (Simeon, Vangelico, FIB)
        -- ==========================================
        "shr_int",
        "post_hiest_unload",
        "jewel2fake",
        "bh1_16_refurb",
        "FIBlobby"
    }

    for _, ipl in pairs(iplsToRemove) do
        RemoveIpl(ipl)
    end

    print("^2[INFO] Les bâtiments (IPL) GTA V par défaut ont été désactivés pour faire place à vos MLOs (Hôpitaux, LTD, etc.)^0")
end)
