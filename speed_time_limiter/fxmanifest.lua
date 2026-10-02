fx_version 'cerulean'
games { 'gta5' }

description 'Standalone Vehicle Speed Limiter and Real-Time Clock Sync'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/speed_limiter.lua',
    'client/time_sync.lua',
    'client/dispatch.lua'
}

server_scripts {
    'server/time_sync.lua'
}
