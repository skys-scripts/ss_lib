local resourceName = GetCurrentResourceName()
local currentLine = "CLNT>UTIL #"

if Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
elseif Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
end

SS_Utils = {

    Notification = function(data)
		if Config.Notification.notifytype == 'ox' then
			lib.notify({
				title = data.title,
				description = data.message,
				type = data.type,
				position = 'top-right',
			})
		elseif Config.Notification.notifytype == 'okok' then
			exports['okokNotify']:Alert(data.title, data.message, 6000, data.type)
		elseif Config.Notification.notifytype == 't-notify' then
			exports['t-notify']:Custom({title = data.title, style = data.type, message = data.message, sound = true})
		end
	end,

	Draw3DText = function(x, y, z, text)
		local boolean, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
		SetTextScale(0.32, 0.32); SetTextFont(4)
		SetTextColour(255, 255, 255, 255)
		BeginTextCommandDisplayText("STRING"); SetTextCentre(true); AddTextComponentSubstringPlayerName(text)
		EndTextCommandDisplayText(_x, _y)
		local factor = (string.len(text) / 500)
		DrawRect(_x, (_y + 0.0125), (0.025 + factor), 0.03, 0, 0, 0, 80)
	end,

    AddLocalEntity = function(entity, args)
		SS_Log("debug", "^4Target System^0] [^3"..Config.TargetSystem.."^0", resourceName,  currentLine.."38")
		if Config.TargetSystem == 'ox-target' then
			exports['ox_target']:addLocalEntity(entity, args.options)
		elseif Config.TargetSystem == 'q-target' then
			if v.onSelect == nil then
				local newOptions = {}
				for k,v in pairs(args.options) do
					table.insert(newOptions, {num = v.num or nil, action = v.onSelect or nil, event = v.event or nil, label = v.label, icon = v.icon})
				end
				exports.qtarget:AddTargetEntity(entity, {
					options = newOptions,
					distance = args.distance,
					canInteract = args.canInteract,
				})
			else
				SS_Log("warn", "[Get ox_target instead of this outdated target system", resourceName, true)
			end
		elseif Config.TargetSystem == 'qb-target' then
			local newOptions = {}
			for k,v in pairs(args.options) do
				local NewFunction = nil
				if v.onSelect ~= nil then
					NewFunction = function(entity)
						local data = {entity = entity, coords = GetEntityCoords(entity)}
						v.onSelect(data)
					end
				end
				table.insert(newOptions, {num = v.num or nil, type = v.type, event = v.event or nil, icon = v.icon, label = v.label, action = NewFunction or nil, canInteract = v.canInteract})
			end
			exports['qb-target']:AddTargetEntity(entity, {
				options = newOptions,
				distance = args.distance,
				canInteract = args.canInteract,
			})
		elseif Config.TargetSystem == 'meta-target' then
			local newOptions = {}
			for k,v in ipairs(args.options) do
				local NewFunction = function(entity)
					local data = {entity = entity, coords = GetEntityCoords(entity)}
					if v.onSelect ~= nil then
						v.onSelect(data)
					else
						TriggerEvent(v.event, data)
					end
				end
				table.insert(newOptions, {label = v.label, index = k, onSelect = NewFunction})
			end
			local canInteract = args.canInteract
			if canInteract then
				canInteract = function(target, pos, ent)
					return args.canInteract(ent)
				end
			end
			exports['meta_target']:addLocalEnt(args.options[1].name, 'NPC', args.options[1].icon, entity, args.distance, false, newOptions, {}, GetInvokingResource(), canInteract or nil)
		end
	end,

    LoadModel = function(model)
		if not HasModelLoaded(model) and IsModelInCdimage(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(0)
			end
		end
        SS_Log("debug","^4Loaded Model^0] [^3"..model.."^0", resourceName, currentLine.."101")
	end,

	CreateObject = function(object, coords, heading, cb, networked)
		networked = networked == nil and true or networked
		if networked then
			SS_Core.TriggerCallback('ss_lib:server:createObject', function(networkId)
				if cb then
					local obj = NetworkGetEntityFromNetworkId(networkId)
					local attempts = 0
					while not DoesEntityExist(obj) do
						obj = NetworkGetEntityFromNetworkId(networkId)
						Wait(10)
						attempts = attempts + 1
						if attempts > 100 then
							break
						end
					end
					cb(obj, networkId)
				end
			end, object, coords, heading)
		else 
			local model = type(object) == 'number' and object or joaat(object)
			local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
			SS_Utils.LoadModel(model)
			local obj = CreateObject(model, vector.xyz, networked, false, true)
			SetEntityRotation(obj, 0, 0, heading, 2, true)
			if cb then
				cb(obj)
			end
		end
	end,

	AddExternalJobXP = function(tier)
		if Config.JobXP.enable then
		local baseXP = Config.JobXP.reward
			if Config.JobXP.useXPMultiplier then
				baseXP = baseXP * Config.Tier.xpMultiplierTable["tier"..tier..""]
			end
			if Config.JobXP.script =='ak4y' then
				TriggerServerEvent('ak4y-jobselector:addXP', baseXP)
			elseif Config.JobXP.script =='custsom' then
				--enter custom trigger event or export here.
			end
		end
	end,

	EmailNotification = function(id,data)
		if Config.Notification.email.type == "qb-phone" then
			TriggerServerEvent("qb-phone:server:sendNewMail", data,id)
		elseif Config.Notification.email.type == "qs-phone" then
			TriggerServerEvent('qs-smartphone:server:sendNewMail', data)
		elseif Config.Notification.email.type == "gks-phone" then
			exports["gksphone"]:SendNewMail(data)
		elseif Config.Notification.email.type == "lb-phone" then
			TriggerServerEvent("ss_lib:server:sendMail", data)
		end
	end,

	GetIdentification = function(data)
		SS_Log("id_debug","^4GetIdentification ^0[^3"..PlayerPedId().."^0]", resourceName, currentLine.."59")
		if Framework == "QB" then
			return QBCore.Functions.GetPlayerData().citizenid
		elseif Framework == "ESX" then
			return ESX.PlayerData.identifier
		end
	end,

	CustomJsonTable = function(tbl)
    local result = "\n"
    for key, value in pairs(tbl) do
        if next(tbl, key) == nil then
            result = result.."[^5"..key.."^0] [^3" .. tostring(value) .. "^0"
        else
            result = result.."[^5"..key.."^0] [^3" .. tostring(value) .. "^0]\n"
        end
    end
        return result
    end,
}

RegisterNetEvent('ss_lib:bridge:utilities:notification', function(msg)
    SS_Utils.Notification(msg)
end)