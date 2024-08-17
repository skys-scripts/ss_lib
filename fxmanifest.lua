fx_version 'cerulean'
game 'gta5'

author 'Sky\'s Scripts'
description 'Library/ compatibility layer for sky\'s scripts'

version '1.0'

shared_scripts {
	'config.lua',
}

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}

escrow_ignore {
	'client/*.lua',
	'server/*.lua',
	'config.lua',
}

lua54 'yes'