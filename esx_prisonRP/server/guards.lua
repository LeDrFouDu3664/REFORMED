RegisterCommand("prisonadmin", function(source, args)
    local isAdmin = false

    local success, result = pcall(function()
        return exports['luxu_admin']:IsAdmin(source)
    end)

    if success and result then
        isAdmin = true
    end

    if not isAdmin then
        -- Fallback to checking group if luxu_admin isn't used
        if GetFramework() == "esx" then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer and (xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "superadmin") then
                isAdmin = true
            end
        elseif GetFramework() == "qbcore" then
            local Player = QBCore.Functions.GetPlayer(source)
            if Player and QBCore.Functions.HasPermission(source, 'admin') then
                isAdmin = true
            end
        end
    end

    if isAdmin then
        TriggerClientEvent('chat:addMessage', source, { args = { '^2[Prison Admin]', 'Menu Admin ouvert (Placeholder).' } })
        -- Trigger Client UI / Menu
    else
        TriggerClientEvent('chat:addMessage', source, { args = { '^1[Erreur]', 'Vous n\'avez pas les permissions.' } })
    end
end, false)
