fx_version 'cerulean'
game 'gta5'

name 'zombie_zones'
description 'Script de zones d\'infection zombie personnalisables pour FiveM'
author 'Jules'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/zones.lua',
    'client/zombies.lua',
    'client/vehicles.lua',
    'client/ambiance.lua',
    'client/admin.lua'
}

server_scripts {
    'server/main.lua'
}
