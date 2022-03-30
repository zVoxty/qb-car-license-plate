fx_version 'cerulean'

game 'gta5'

lua54 'yes'

description 'QB-CarLicencePlate'

version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
	'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/fonts/*.ttf',
    'html/css/style.css',
    'html/js/script.js'
}

