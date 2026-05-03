local hasSeenTutorial = false

RegisterNetEvent("prison:client:showTutorial")
AddEventHandler("prison:client:showTutorial", function()
    if hasSeenTutorial then return end
    hasSeenTutorial = true

    Citizen.CreateThread(function()
        -- Replace with actual NUI or proper notification sequence
        -- ShowNotification("~b~Bienvenue en prison.~s~")
        Citizen.Wait(3000)
        -- ShowNotification("~y~Suivez le planning pour réduire votre peine.~s~")
        Citizen.Wait(3000)
        -- ShowNotification("~g~Trouvez un travail pour gagner de l'argent interne.~s~")

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "showTutorial",
            steps = {
                "Bienvenue en prison.",
                "Suivez le planning pour réduire votre peine.",
                "Trouvez un travail pour gagner de l'argent interne."
            }
        })
    end)
end)

RegisterNUICallback('closeTutorial', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
