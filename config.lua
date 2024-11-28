Config = {
    -- Any Lang options can be found in the language.lua file as what is in the square brackets i.e [example] = "test this later",
	Triggers = {
		['ESX'] = { -- update your triggers or event-names here if you've changed them from default values:
			resource = 'es_extended', -- esx resource name
			obj = 'esx:getSharedObject',
			load = 'esx:playerLoaded',
			job = 'esx:setJob',
            playerdatabase = 'users', -- This is the table that is used for for your player's indentifier or citizenid 
            playerid = 'identifier'
		},
		['QB'] = { -- update your triggers or event-names here if you've changed them from default values
			resource = 'qb-core', -- qb-core resource name
			obj = 'QBCore:GetObject',
			load = 'QBCore:Client:OnPlayerLoaded',
			job = 'QBCore:Client:OnJobUpdate',
			uObjCL = 'QBCore:Client:UpdateObject',
			uObjSV = 'QBCore:Server:UpdateObject',
			dutyToggle = 'QBCore:ToggleDuty',
            playerdatabase = 'players', -- This is the table that is used for for your player's indentifier or citizenid 
            playerid = 'citizenid'
		},
	},

    AdminOptions = {
        enable = true,-- This is used for allowing commands through admin perms to be run (set by ace permmissions) on player load
        ranks = {"admin","superadmin","command","group.admin","qbcore.god"}, -- Ace permission ranks allowed to use the admin commands for altering xp amounts of players.
    },

	Debug = {
        enable = true, -- To enable standard debug prints set to true.
        idType = false, -- For ID debug prints (getting source or identifier etc). This requires Debug.enable to be set to true.
    },

    VehicleKeys = "qb",

    Doorlock = "qb",

    Fuel = "LegacyFuel",

    Inventory = "qb",
    
    Notification = {
        enable = true,-- If enabled you can send nofitications when xp is added, removed/spent.
        notifytype = "qb",  --'qb', 'ox', 'okok', 'esx' 
        email = { -- If enabled emails will be triggered when you level up or down a skill.
            enable = true,
            type = 'qb-phone', -- 'lb-phone', 'qb-phone', 'qs-phone'. if a phone is used it will send an email else if 'nil' it will be a standard Notification
        },
    },

}

Framework = GetResourceState(Config.Triggers["QB"].resource):find('started') and 'QB' or GetResourceState(Config.Triggers["ESX"].resource):find('started') and 'ESX' -- Credit to t1ger for the framework config.