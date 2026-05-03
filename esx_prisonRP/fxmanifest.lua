fx_version 'cerulean'
game 'gta5'

author 'Reformed'
description 'Systeme de Prison RP Complet Multi-Framework'
version '1.0.0'

shared_scripts {
    'config.lua',
    'bridge/shared.lua'
}

client_scripts {
    'bridge/client/*.lua',
    'client/main.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/*.lua',
    'server/main.lua',
    'server/*.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'locales/*.json'
}

dependencies {
    'oxmysql'
}
