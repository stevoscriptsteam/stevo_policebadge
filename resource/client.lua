if not lib.checkDependency('stevo_lib', '1.6.0') then error('You need to update stevo_lib to the latest version for stevo_policebadges.') end
lib.locale()

local config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local CURRENTLY_USING_BADGE = false


local function showBadge()
    CURRENTLY_USING_BADGE = true
    local badge_data = lib.callback.await("stevo_policebadge:retrieveInfo", false)

    SendNUIMessage({ type = "displayBadge", data = badge_data })

    local players = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), 3, false)
    if #players > 0 then
        local ply = {}
        for i = 1, #players do
            table.insert(ply, GetPlayerServerId(players[i].id))
        end
        TriggerServerEvent('stevo_policebadge:showbadge', badge_data, ply)
    end

    lib.progressBar({
        duration = config.badge_show_time,
        label = locale('progress_label'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = "paper_1_rcm_alt1-8",
            clip = "player_one_dual-8"
        },
        prop = {
            bone = 28422,
            model = "prop_fib_badge",
            pos = vec3(0.0600,0.0210,-0.0400),
            rot = vec3(-90.00,-180.00,78.999)
        },
    })

    CURRENTLY_USING_BADGE = false
end

RegisterNetEvent('stevo_policebadge:use', function()
    local job, gang = stevo_lib.GetPlayerGroups()
    local swimming = IsPedSwimmingUnderWater(cache.ped)
    local incar = IsPedInAnyVehicle(cache.ped, true)
    local job_auth = false

    
    for _, group in pairs (config.job_names) do    
        if group == job then 
            job_auth = true
        end
    end

    if not job_auth then return stevo_lib.Notify(locale('not_police'), 'error', 3000) end

    if swimming or incar then return stevo_lib.Notify(locale('not_now'), 'error', 3000) end

    if CURRENTLY_USING_BADGE then return end

    showBadge()
end)

RegisterNetEvent('stevo_policebadge:displaybadge')
AddEventHandler('stevo_policebadge:displaybadge', function(data)
    SendNUIMessage({ type = "displayBadge", data = data })
end)

RegisterCommand(config.set_image_command, function()
    local job, gang = stevo_lib.GetPlayerGroups()

    local job_auth = false

    
    for _, group in pairs (config.job_names) do    
        if group == job then 
            job_auth = true
        end
    end

    if not job_auth then stevo_lib.Notify(locale('not_police'), 'error', 3000) return end


    local input = lib.inputDialog(locale('input_title'), {locale('input_text')})
 
    if not input then stevo_lib.Notify(locale('no_photo'), 'error', 3000) return end

    local setBadge = lib.callback.await("stevo_policebadge:setBadgePhoto", false, input[1])
    if setBadge then
        lib.alertDialog({
            header = locale('department_name'),
            content = locale('update_badge_photo_success'),
            centered = true,
            cancel = false
        })
    else
        lib.alertDialog({
            header = locale('department_name'),
            content = locale('update_badge_photo_fail'),
            centered = true,
            cancel = false
        })
    end
end, false)
