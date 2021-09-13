local ESX

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent("zFishing:startFishing")
AddEventHandler("zFishing:startFishing", function(fishingZoneId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local haveFishingRod = (xPlayer.getInventoryItem(Config.fishingRod).count >= 1)
    if not haveFishingRod then
        TriggerClientEvent("zFishing:setFishingState", _src, false, "~r~Vous n'avez pas de canne à pêche")
        return
    end
    TriggerClientEvent("zFishing:startFishing", _src, fishingZoneId)
    Wait(1000)
    SetTimeout(math.random(1, 20000), function()
        xPlayer = ESX.GetPlayerFromId(_src)
        if not xPlayer then return end
        local reward = Config.availableFish[math.random(#Config.availableFish)]
        local rewardCount = math.random(3)
        xPlayer.addInventoryItem(reward, rewardCount)
        TriggerClientEvent("zFishing:stopFishing", _src, "~g~Vous avez pêché ~y~"..rewardCount.." ~y~"..ESX.GetItemLabel(reward).." ~g~!")
    end)
end)

RegisterNetEvent("zFishing:sellfishs")
AddEventHandler("zFishing:sellfishs", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local total = 0
    for k,v in pairs(Config.availableFish) do
        local count = xPlayer.getInventoryItem(v).count
        if count > 0 then
            xPlayer.removeInventoryItem(v, count)
            total = total + (Config.vendor.fishResell[v:lower()]*count)
        end
    end
    if total <= 0 then
        TriggerClientEvent("esx:showNotification", _src, "~r~Vous n'avez rien vendu !")
        return
    end
    TriggerClientEvent("esx:showNotification", _src, "~g~Vous avez vendu tous vos poissons pour "..total.."$")
    xPlayer.addMoney(total)
end)