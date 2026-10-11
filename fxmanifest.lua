fx_version 'cerulean'
game 'gta5'

description 'Custom QBCore Inventory UI'
author 'Jules'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/images/*.png',
    'html/images/*.svg',
    'html/images/*.jpg'
}
