return {
    job_names = {'police', 'sheriff'}, -- Police job names.
    badge_show_time = 5000, -- Time badge should display

    set_image_command = 'setbadgephoto', -- Command to change badge photo

    locales = {
        department_name = 'Victoria Police',
        progress_label = 'Showing Badge',
        not_police = 'You are not a police officer!',
        not_now = 'You cannot use this now!', -- If Player tries to use badge underwater or inside car.
        input_title = 'Badge Photo',
        input_text = 'Badge Photo URL',
        no_photo = 'You didnt enter a photo',
        update_badge_photo_success = 'Successfully updated your Badge Photo!',
        update_badge_photo_fail = 'Failed to set new Badge Photo, try again!'
    },
}