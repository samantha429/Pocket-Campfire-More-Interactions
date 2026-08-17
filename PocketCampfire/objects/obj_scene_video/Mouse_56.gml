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

if(selected_button < mode_count)
{
    target_mode = selected_button;

    fading = true;
    fade_dir = 1;
    target_phase = 0;
}
else
{
    var phase_button = selected_button - mode_count;

    if(phase_button < 3)
    {
        fading = true;
        fade_dir = 1;
        target_phase = phase_button;
    }
	else
	{
	    // Cum / end phase
	    current_phase = 3;
	    video_last_position = -100;

	    // Do NOT attempt to open another video.
	    // The current video must be closed first.
	    if (video_get_status() != video_status_closed)
	    {
	        video_close();
	    }

	    video_close_pending = false;
	    video_open_pending = false;

	    // Continue to the end/refraction sequence
	    event_user(3);
	}
}