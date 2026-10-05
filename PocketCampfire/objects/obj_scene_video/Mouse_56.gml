/// @description Insert description here

if(fading || finished || video_close_pending || video_open_pending || global.game_state == GAME_STATE.LOCKED) { return; }

if(selected_menubutton != -1)
{
	switch(selected_menubutton)
	{
		case 0:
			scr_create_confirmation("Are you sure you want to leave?", scr_abort_scene); 
			break;
		case 1:
			scr_open_settings();
			break;
		case 2:
			voice_enabled = !voice_enabled;
			with(obj_sound_manager) 
			{
				human_voice_enabled = other.voice_enabled;
				event_user(0);
			}
		break;
	}
	
	return;
}

if(selected_button == -1) 
{
	if(current_phase == 4) 
	{ 
		scr_end_scene();
		alarm[1] = 1 * global.game_speed; 
		finished = true;
	}
	return; 
}

if(selected_button < mode_button_count)
{
    var _target_mode_index = -1;

    switch(selected_button)
    {
        case 0:
            _target_mode_index = oral_mode_index;
        break;
        case 1:
            _target_mode_index = sex_mode_index;
        break;
        case 2:
            if(array_length(cycle_mode_indices) > 0)
            {
                cycle_position = (cycle_position + 1) mod array_length(cycle_mode_indices);
                _target_mode_index = cycle_mode_indices[cycle_position];
            }
        break;
    }

    if(_target_mode_index != -1)
    {
        target_mode = _target_mode_index;

        fading = true;
        fade_dir = 1;
        target_phase = 0;
    }
}
else
{
    var phase_button = selected_button - mode_button_count;

    if(phase_button < 3)
    {
        fading = true;
        fade_dir = 1;
        target_phase = phase_button;
    }
    else
    {
        // Finish: phase 3 is the cum clip. The swap handler closes the
        // current video and opens clips[3], so don't touch the player here.
        current_phase = 3;
        video_last_position = -100;
        event_user(3);
    }
}