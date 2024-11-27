ESX = nil
QBCore = nil
local resourceName = GetCurrentResourceName()
local currentLine = "CLNT>FRAME #"

if Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
elseif Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
end

SS_Core = {

    PlayerData = {},
    PlayerJob = {},

    FrameworkReady = function()
        if Framework == 'ESX' then
            while not ESX do Wait(500); end 
            while ESX.GetPlayerData().job == nil do
                Wait(500)
            end
            SS_Core.PlayerData = SS_Core.GetPlayerData()
            return true
        elseif Framework == 'QB' then
            while not QBCore do Wait(500); end
            while not QBCore.Functions.GetPlayerData().job do Wait(500); end
            SS_Core.PlayerData = SS_Core.GetPlayerData()
            return true
        end
        return true
    end,

    SpawnVehicle = function(model, coords, heading, cb, networked)
        if Framework == 'ESX' then
            ESX.Game.SpawnVehicle(model, coords, heading, cb, networked)
        elseif Framework == 'QB' then
            QBCore.Functions.SpawnVehicle(model, cb, coords, networked)
        end
        SS_Log("debug","^4SpawnVehicle^0] [^3"..tostring(model).."^0", resourceName, currentLine.."40")
	end,

    DeleteVehicle = function(vehicle)
        if Framework == 'ESX' then
            ESX.Game.DeleteVehicle(vehicle)
        elseif Framework == 'QB' then
            QBCore.Functions.DeleteVehicle(vehicle)
        end
        SS_Log("debug","^4DeleteVehicle^0] [^3"..tostring(vehicle)"^0", resourceName, currentLine.."49")
    end,

    TriggerCallback = function(name, cb, ...)
        SS_Log("debug","^4TriggerCallback ^0[^3"..name.."^0", resourceName, currentLine.."53")
        if Framework == 'ESX' then
            ESX.TriggerServerCallback(name, cb, ...)
        elseif Framework == 'QB' then
            QBCore.Functions.TriggerCallback(name, cb, ...)
        end
        SS_Log("debug","^4TriggerCallback Finished ^0[^3"..name.."^0", resourceName, currentLine.."59")
    end,

    SetPlayerJob = function()
        local table = {}
        while not SS_Core.PlayerData.job do
            Wait(200)
        end
        if Framework == 'ESX' then
            table.name = SS_Core.PlayerData.job.name
            table.label = SS_Core.PlayerData.job.label
            table.grade = SS_Core.PlayerData.job.grade
            table.gradeLabel = SS_Core.PlayerData.job.grade_label
            table.onDuty  = "N/A"
            --table.isPolice = Config.PoliceJobs[SS_Core.PlayerData.job.name] or false
        elseif Framework == 'QB' then
            table.name  = SS_Core.PlayerData.job.name
            table.label = SS_Core.PlayerData.job.label
            table.grade  = SS_Core.PlayerData.job.grade.level
            table.rank  = SS_Core.PlayerData.job.grade.name
            table.onDuty  = SS_Core.PlayerData.job.onduty or false
            --table.isPolice = Config.PoliceJobs[SS_Core.PlayerData.job.name] or false
        end
        SS_Log("debug","^4Job^0] [^3"..table.label.."^0] [^4Title^0] [^3"..table.name.."^0] [^4Duty^0] [^3"..tostring(table.onDuty).."^0] [^4Grade^0] [^3"..table.grade.."^0]", resourceName, currentLine.."82")
        SS_Core.PlayerJob = table
    end,

    GetPlayerData = function()
        if Framework == 'ESX' then
            SS_Core.PlayerData = ESX.GetPlayerData()
            SS_Core.SetPlayerJob()
            return ESX.GetPlayerData()
        elseif Framework == 'QB' then
            SS_Core.PlayerData = QBCore.Functions.GetPlayerData()
            SS_Core.SetPlayerJob()
            return QBCore.Functions.GetPlayerData()
        end
    end,

    GetPlayerMoney = function(cb, account) -- Needs more testing???
        SS_Core.TriggerCallback('ss-truckjob:server:getMoney', function(money)
            cb(money)
        end, account or nil)
    end,

    GetJob = function()
        return SS_Core.PlayerJob
    end,

    Notification = function(data)
        if Config.Notification.enable then
            if Config.Notification.notifytype == 'qb' or Config.Notification.notifytype == 'esx' then
                if ESX ~= nil then
                    ESX.ShowNotification(data.message, false, true, nil)
                elseif QBCore ~= nil then
                    QBCore.Functions.Notify(data.message)
                end
            elseif Config.Notification.notifytype == 'ox' then
                SS_Utils.Notification(data)
            elseif Config.Notification.notifytype == 'okok' then
                SS_Utils.Notification(data)
            end
        end
    end,

    SetFuelAmount = function(vehicle,fuelAmount)
        if Config.Fuel == "LegacyFuel" then
            exports['LegacyFuel']:SetFuel(vehicle, fuelAmount)
        elseif Config.Fuel == "cdn-fuel" then
            exports['cdn-fuel']:SetFuel(vehicle, fuelAmount)
        elseif Config.Fuel == "ps-fuel" then
            exports['ps-fuel']:SetFuel(vehicle, fuelAmount)
        elseif Config.Fuel == "okok" then
            exports['okokGasStation']:SetFuel(vehicle, fuelAmount)
        elseif Config.Fuel == "custom" then
            -- Add custom set fuel function here
        end
        SS_Log("debug","^4SetFuelAmount^0] [^3Vehicle - "..vehicle.." ^0] [^3Fuel Amount - "..fuelAmount.."^0]", resourceName, currentLine.."127")
    end,

    SetOwner = function(vehicle)
        local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        SS_Log("debug","^4Set Owner^0] [^4Vehicle Plate^0] [^3 "..plate.."^0] [^4Vehicle Model^0] [^3 "..model.."^0", resourceName, currentLine.."133")
        if Framework == "QB" then
            if Config.Keys == "default" then
                TriggerEvent("vehiclekeys:client:SetOwner",plate) -- replace your vehicle key option here. (setowner)
            end
        elseif Config.Keys == "qs" then
            exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
        elseif Config.Keys == "default" and Framework == "ESX" then
            -- add custom TriggerEvent
        end
    end
}

RegisterNetEvent(Config.Triggers[Framework].job)
AddEventHandler(Config.Triggers[Framework].job, function(job)
    SS_Core.PlayerData.job = job
    SS_Core.SetPlayerJob()
end)