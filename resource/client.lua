local Config = lib.require('config')
local stevo_lib = exports['stevo_lib']:import()
local currently_using_badge = false


RegisterNetEvent('stevo_policebadge:displaybadge')
AddEventHandler('stevo_policebadge:displaybadge', function(data)
    SendNUIMessage({ type = "displayBadge", data = data })
end)

local function show_badge()
    local currently_using_badge = true
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
        duration = Config.badge_show_time,
        label = Config.locales.progress_label,
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

    currently_using_badge = false
end

exports('use', function()
    local job, gang = stevo_lib.GetPlayerGroups()
    local ped = PlayerPedId()
    local swimming = IsPedSwimmingUnderWater(ped)
    local incar = IsPedInAnyVehicle(ped, true)
    local job_auth = false

    
    for _, group in pairs (Config.job_names) do    
        if group == job then 
            job_auth = true
        end
    end

    if job_auth then 
        return stevo_lib.Notify(Config.locales.not_police, 'error', 3000) 
    elseif swimming or incar then         
        return stevo_lib.Notify(Config.locales.not_now, 'error', 3000) 
    elseif not currently_using_badge then 
        show_badge()
    end
end)

RegisterCommand(Config.set_image_command, function()
    local job, gang = stevo_lib.GetPlayerGroups()

    if job ~= Config.job_name then return stevo_lib.Notify(Config.locales.not_police, 'error', 3000) end


    local input = lib.inputDialog(Config.locales.input_title, {Config.locales.input_text})
 
    if not input then stevo_lib.Notify(Config.locales.no_photo, 'error', 3000) return end

    local setBadge = lib.callback.await("stevo_policebadge:setBadgePhoto", false, input[1])
    if setBadge then
        lib.alertDialog({
            header = Config.locales.department_name,
            content = Config.locales.update_badge_photo_success,
            centered = true,
            cancel = false
        })
    else
        lib.alertDialog({
            header = Config.locales.department_name,
            content = Config.locales.update_badge_photo_fail,
            centered = true,
            cancel = false
        })
    end
end, false)