local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')
lib.locale()

lib.callback.register("stevo_policebadge:retrieveInfo", function(source)
    local badge_data = {}

    local identifier = stevo_lib.GetIdentifier(source)
    local job, gang = stevo_lib.GetPlayerGroups(source)

    badge_data.rank = job.grade ~= nil and job.grade.name or job.grade_label
    badge_data.name = stevo_lib.GetName(source)
    
    local table = MySQL.single.await('SELECT `image` FROM `stevo_badge_photos` WHERE `identifier` = ? LIMIT 1', {
        identifier
    })
     
    badge_data.photo = table ~= nil and table.image or nil
    
    print(badge_data.photo)
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

CreateThread(function()
    local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM stevo_badge_photos')

    if not success then
        MySQL.query([[CREATE TABLE IF NOT EXISTS `stevo_badge_photos` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(50) NOT NULL,
        `image` longtext NOT NULL,
        PRIMARY KEY (`id`)
        )]])
        print('[Stevo Scripts] Deployed database table for stevo_badge_photos')
    end

    stevo_lib.RegisterUsableItem(config.badge_item_name, function(source)
        TriggerClientEvent('stevo_police_badge', source)
    end)
end)