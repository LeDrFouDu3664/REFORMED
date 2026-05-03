Bridge = {}
Bridge.Framework = nil

function GetFramework()
    if Config.Framework ~= "auto" then
        return Config.Framework
    end

    if GetResourceState('es_extended') == 'started' then
        return "esx"
    elseif GetResourceState('qb-core') == 'started' then
        return "qbcore"
    end

    return "unknown"
end

Citizen.CreateThread(function()
    Bridge.Framework = GetFramework()
    print("[Prison] Framework détecté: " .. Bridge.Framework)
end)
