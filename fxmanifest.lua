fx_version 'cerulean'
game 'gta5'

name 'zombie_zones'
description 'Script de zones d\'infection zombie et de contamination pour FiveM'
author 'Jules'
version '1.1.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua'
}

client_scripts {
    'client/zones.lua',
    'client/zombies.lua',
    'client/vehicles.lua',
    'client/ambiance.lua',
    'client/infection.lua',
    'client/props.lua',
    'client/admin.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

extra_database_decl 'schema.sql'
