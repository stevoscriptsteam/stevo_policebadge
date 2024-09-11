lib.versionCheck('stevoscriptsteam/stevo_policebadge')
if not lib.checkDependency('stevo_lib', '1.6.7') then error('You need to update stevo_lib to the latest version for stevo_policebadges.') end
lib.locale()

local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')


lib.callback.register("stevo_policebadge:retrieveInfo", function(source)
    local badge_data = {}
    local identifier = stevo_lib.GetIdentifier(source)
    local job = stevo_lib.GetPlayerJobInfo(source)

    
    badge_data.rank = job.gradeName  or "Unknown" 

    badge_data.name = stevo_lib.GetName(source)
    
    
    local table = MySQL.single.await('SELECT `image` FROM `stevo_badge_photos` WHERE `identifier` = ? LIMIT 1', {
        identifier
    })
     
    badge_data.photo = table ~= nil and table.image or nil
    
    return badge_data
end)

lib.callback.register("stevo_policebadge:setBadgePhoto", function(source, photo)
    local identifier = stevo_lib.GetIdentifier(source)


    local image = MySQL.single.await('SELECT `image` FROM `stevo_badge_photos` WHERE `identifier` = ? LIMIT 1', {
        identifier
    })

    local id 

    if not image then 
        id = MySQL.insert.await('INSERT INTO `stevo_badge_photos` (identifier, image) VALUES (?, ?)', {
            identifier, photo
        })
    else 
        id = MySQL.update.await('UPDATE `stevo_badge_photos` SET image = ? WHERE identifier = ?', {
            photo, identifier
        })
    end
    return id
end)

RegisterNetEvent('stevo_policebadge:showbadge')
AddEventHandler('stevo_policebadge:showbadge', function(data, ply)
    for i, player in pairs(ply) do
        TriggerClientEvent('stevo_policebadge:displaybadge', player, data)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local tableExists, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_badge_photos')

    if not tableExists then
        MySQL.query([[CREATE TABLE IF NOT EXISTS `stevo_badge_photos` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(50) NOT NULL,
        `image` longtext NOT NULL,
        PRIMARY KEY (`id`)
        )]])

        lib.print.info('[Stevo Scripts] Deployed database table for stevo_badge_photos')
    end

    stevo_lib.RegisterUsableItem(config.badge_item_name, function(source)
        TriggerClientEvent('stevo_policebadge:use', source)
    end)
end)

