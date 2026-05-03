local lastJobTime = {}
local activeJobs = {}

RegisterNetEvent("prison:server:startJob")
AddEventHandler("prison:server:startJob", function(jobName)
    local _source = source
    activeJobs[_source] = { name = jobName, time = os.time() }
end)

RegisterNetEvent("prison:server:completeJob")
AddEventHandler("prison:server:completeJob", function(jobName)
    local _source = source
    local reward = Config.JobRewards[jobName]

    if not reward then return end

    -- Verify active job flag and duration
    local activeJob = activeJobs[_source]
    if not activeJob or activeJob.name ~= jobName or (os.time() - activeJob.time) < 9 then
        print(("[Prison] Tentative d'exploit détectée par l'ID %s. A tenté de terminer un job illégalement."):format(_source))
        return
    end

    -- Clear flag
    activeJobs[_source] = nil

    -- Check distance
    local targetCoords = Config.Locations.Jobs[jobName]
    local ped = GetPlayerPed(_source)
    local pos = GetEntityCoords(ped)
    if #(pos - targetCoords) > 10.0 then
        print(("[Prison] Tentative d'exploit détectée par l'ID %s. Trop loin des coordonnées du job."):format(_source))
        return
    end

    -- Anti-spam cooldown (10 seconds)
    if lastJobTime[_source] and (os.time() - lastJobTime[_source]) < 10 then
        -- Notify spam
        return
    end
    lastJobTime[_source] = os.time()

    -- Verify job (basic check, expand with framework specific job checks if necessary)
    local playerJob = GetPlayerJob(_source)
    local isPrisoner = false
    for _, pJob in ipairs(Config.PrisonerJobs) do
        if playerJob == pJob then
            isPrisoner = true
            break
        end
    end

    if isPrisoner then
        AddPlayerMoney(_source, reward)
        local identifier = GetPlayerIdentifier(_source)
        if identifier then
            ReducePlayerJailTime(_source, identifier, Config.JobTimeReduction)
        end
        -- Notification handled via client bridge if needed
    end
end)
