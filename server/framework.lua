ESX = nil
QBCore = nil
local resourceName = GetCurrentResourceName()
local currentLine = "SRVR>FRAME #"

if Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
elseif Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
end


SS_Core = {

    Notification = function(src, data)
        if Config.Notification.enable then
            if Framework == 'ESX' then
                TriggerClientEvent('esx:showNotification', src, data.message)
            elseif Framework == 'QB' then
                TriggerClientEvent('QBCore:Notify', src, data.message)
            end
        else
            TriggerClientEvent('ss_lib:bridge:utilities:notification', src, data)
        end
    end,

    RegisterCallback = function(name, cb)
        SS_Log("debug", "^4RegisterCallback ^0[^3"..name.."^0]", resourceName, false, currentLine.."28")
        if Framework == 'ESX' then
            ESX.RegisterServerCallback(name, cb)
        elseif Framework == 'QB' then
            QBCore.Functions.CreateCallback(name, cb)
        end
    end,
}

SS_Core.Player = {

    GetSource = function(src)
        local xPlayer = SS_Core.Player.GetFromId(tonumber(src))
        while xPlayer == nil do
            Wait(500)
            xPlayer = SS_Core.Player.GetFromId(tonumber(src))
        end
        SS_Log("debug", "^4Server Side - GetSource ^0[^3"..tonumber(src).."^0]", resourceName, false, currentLine.."45")
        if Framework == 'ESX' then
            return xPlayer.source
        elseif Framework == 'QB' then
            return xPlayer.PlayerData.source
        end
    end,

    GetFromId = function(src)
        SS_Log("debug", "^4Server Side - GetFromId ^0[^3"..(src).."^0]", resourceName, false, currentLine.."54")
        if Framework == 'ESX' then
            return ESX.GetPlayerFromId(src)
        elseif Framework == 'QB' then
            return QBCore.Functions.GetPlayer(src)
        end
    end,

    GetIdentifier = function(src)
        SS_Log("debug", "^4Server Side - GetIdentifier ^0[^3"..tonumber(src).."^0]", resourceName, false, currentLine.."63")
        local Player = SS_Core.Player.GetFromId(tonumber(src))
        if Framework == 'ESX' then
            return Player.identifier
        elseif Framework == 'QB' then
            return Player.PlayerData.citizenid
        end
    end,

    GetCitizenName = function(src)
        SS_Log("debug", "^4Server Side - GetCitizenName ^0[^3"..tonumber(src).."^0]", resourceName, false, currentLine.."73")
        local Player = SS_Core.Player.GetFromId(tonumber(src))
        if Framework == 'ESX' then
            return Player.getName()
        elseif Framework == 'QB' then
            return Player.PlayerData.charinfo.firstname.. " "..Player.PlayerData.charinfo.lastname
        end
    end,

    AddItem = function(src, item, amount)
        local src = SS_Core.Player.GetSource(src)
        local Player = SS_Core.Player.GetFromId(src)
        if Framework == 'ESX' then 
            Player.addInventoryItem(item, amount)
        elseif Framework == 'QB' then
            if item == 'markedbills' then
                local meta = {
                    worth = amount
                }
                Player.Functions.AddItem(item, 1, false, meta)
                TriggerClientEvent('inventory:client:ItemBox', src,QBCore.Shared.Items[item], "add")
            elseif item ~= 'markedbills' then
                Player.Functions.AddItem(item, amount)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[i], "add")
            end
        end
    end,

    AddMoney = function(src, amount, account)
        local Player = SS_Core.Player.GetFromId(tonumber(src))
        if Framework == 'ESX' then 
            if account == nil then
                Player.addMoney(tonumber(amount))
            else
                Player.addAccountMoney(account, tonumber(amount))
            end
        elseif Framework == 'QB' then
            if account == nil then
                Player.Functions.AddMoney("cash", tonumber(amount))
            else
                Player.Functions.AddMoney(tostring(account), tonumber(amount))
            end 
        end
    end,

    RemoveItem = function(src, item, amount)
        local src = SS_Core.Player.GetSource(src)
        local player = SS_Core.Player.GetFromId(src)
        if Framework == 'ESX' then 
            player.removeInventoryItem(item, amount)
        elseif Framework == 'QB' then
            player.Functions.RemoveItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
        end
    end,

    RemoveMoney = function(src, amount, account)
        local Player =  SS_Core.Player.GetFromId(tonumber(src))
        if Framework == 'ESX' then
            if account == nil then
                Player.removeMoney(tonumber(amount))
            else
                Player.removeAccountMoney(account, tonumber(amount))
            end
        elseif Framework == 'QB' then
            if account == nil then
                Player.Functions.RemoveMoney("cash", tonumber(amount))
            else
                Player.Functions.RemoveMoney(tostring(account), tonumber(amount))
            end 
        end
    end,

    GetMoney = function(src, account)
        local player = SS_Core.Player.GetFromId(tonumber(src))
        if ESX ~= nil then
            if account == nil then
                return player.getMoney()
            else
                return player.getAccount(account).money
            end
        elseif QBCore ~= nil then
            if account == nil then
                return player.Functions.GetMoney("cash")
            else
                return player.Functions.GetMoney(account)
            end
        end
    end,

    IsAdmin = function(src)
        local permissions = Config.AdminOptions.ranks
        SS_Log("debug", "^4Admin ranks able to use commands^0: ^3"..json.encode(permissions).."^0", resourceName, false, currentLine.."83")
        for k,v in pairs(permissions) do
            if IsPlayerAceAllowed(src, v) then
                SS_Log("debug", "^4Admin Perm Granted ^0[^3"..src.."^0] ^4Level:^0 [^3"..v.."^0]", resourceName, false, currentLine.."86")
                return true
            end
        end
        return false
    end,
}

SS_Core.RegisterCallback("ss_lib:server:CheckAdminCommands", function(source, cb)
    cb(SS_Core.Player.IsAdmin(source))
end)

SS_Core.RegisterCallback("ss_lib:server:getPlayerName", function(source, cb, oID)
    local name = nil
    if oID == nil then
        name = SS_Core.Player.GetCitizenName(source)
    else
        name = SS_Core.Player.GetCitizenName(oID)
    end
    cb(tostring(name.." ["..(oID or source).."]"))
end)