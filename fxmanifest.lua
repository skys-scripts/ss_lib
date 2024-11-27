fx_version 'cerulean'
game 'gta5'

author 'Sky\'s Scripts'
description 'Library/ compatibility layer for sky\'s scripts'

version '0.2.0'

shared_scripts {
	'@ox_lib/init.lua',
	'language.lua',
	'config.lua',
	'shared/*.lua',
}

server_scripts {
	'server/*.lua',
	'shared/logging.lua',
}

client_scripts {
	'client/*.lua',
	'shared/logging.lua',
}

escrow_ignore {
	'client/*.lua',
	'server/*.lua',
	'shared/*.lua',
	'language.lua',
	'config.lua',
}

lua54 'yes'