fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author "Stevo Scripts | Steve & Blacklist"
description 'Badge system for police to prove identity.'
version '1.5.6'

ui_page 'resource/web/index.html'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'resource/client.lua',
}

server_scripts {
    'resource/server.lua',
    '@oxmysql/lib/MySQL.lua'
}


files {
    'resource/web/index.html',
    'resource/web/*.css',
    'resource/web/*.js',
    'resource/web/img/badge.png',
    'resource/web/img/none.png',
    'resource/web/fonts/roboto/*.woff',
    'resource/web/fonts/roboto/*.woff2',
    'locales/*.json'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'stevo_lib'
}
