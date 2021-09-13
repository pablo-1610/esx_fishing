local ESX, currentFishing

RegisterNetEvent("zFishing:setFishingState")
AddEventHandler("zFishing:setFishingState", function(state, message)
    currentFishing = state
    if message then ESX.ShowNotification(message) end
end)

RegisterNetEvent("zFishing:startFishing")
AddEventHandler("zFishing:startFishing", function(fishingZoneId)
    currentFishing = true
    local heading = Config.fishingZones[fishingZoneId].heading
    TaskStartScenarioAtPosition(PlayerPedId(), "WORLD_HUMAN_STAND_FISHING", GetEntityCoords(PlayerPedId()), heading, -1, false, true)
    --ESX.ShowNotification("~o~Vous commencez à pecher...")
    while currentFishing do
        Wait(1)
        DisableControlAction(0, 73, true)
    end
end)

RegisterNetEvent("zFishing:stopFishing")
AddEventHandler("zFishing:stopFishing", function(message)
    if not currentFishing then return end
    if message then ESX.ShowNotification(message) end
    currentFishing = false
    ClearPedTasksImmediately(PlayerPedId())
    local obj, dst = ESX.Game.GetClosestObject()
    local isFishingRod = (GetEntityModel(obj) == -1910604593)
    if isFishingRod then
        NetworkRequestControlOfEntity(obj)
        while not NetworkHasControlOfEntity(obj) do
            Wait(10)
        end
        SetEntityAsMissionEntity(obj, 0,0)
        DeleteEntity(obj)
    end
end)

Citizen.CreateThread(function()
    TriggerEvent("esx:getSharedObject", function(obj)
        ESX = obj
    end)
    currentFishing = false
    for k,v in pairs(Config.fishingZones) do
        local blip = AddBlipForCoord(v.zoneCenter)
        SetBlipSprite(blip, Config.blips.sprite)
        SetBlipColour(blip, Config.blips.color)
        SetBlipScale(blip, Config.blips.size)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(Config.blips.name)
		EndTextCommandSetBlipName(blip)

        local area = AddBlipForRadius(v.zoneCenter, v.radius)
        SetBlipAlpha(area, 100)
        SetBlipColour(area, Config.blips.color)
    end

    
    if Config.vendor.blipActive then
        local vendorBlip = AddBlipForCoord(Config.vendor.position)
        SetBlipSprite(vendorBlip, Config.vendor.sprite)
        SetBlipColour(vendorBlip, Config.vendor.color)
        SetBlipScale(vendorBlip, Config.vendor.size)
        SetBlipAsShortRange(vendorBlip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.vendor.name)
        EndTextCommandSetBlipName(vendorBlip)
    end

    while true do
        local interval = 250
        local playerPos = GetEntityCoords(PlayerPedId())
        if not currentFishing then
            for k,v in pairs(Config.fishingZones) do
                local zoneCenter = v.zoneCenter
                local dst = #(playerPos-zoneCenter)
                if dst <= v.radius then
                    interval = 0
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour commencer à pêcher dans cette zone")
                    if IsControlJustPressed(0, 51) then
                        currentFishing = true
                        TriggerServerEvent("zFishing:startFishing", k)
                    end
                end
            end

            local vendorZone = Config.vendor.position
            local dst = #(playerPos-vendorZone)
            if dst <= 30.0 then
                interval = 0
                DrawMarker(22, vendorZone, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                if dst <= 1.0 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour vendre tous vos poissons")
                    if IsControlJustPressed(0, 51) then
                        TriggerServerEvent("zFishing:sellfishs")
                    end
                end
            end
        end
        Wait(interval)
    end
end)