fx_version 'cerulean'
game 'gta5'

author 'Jules'
description 'Prison RP Complet - Police, Garde, EMS'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', -- Remplace par '@oxmysql/lib/MySQL.lua' si tu utilises oxmysql
    'server.lua'
}
