/// @description Start New Video

// We should only arrive here after the previous video is closed.
if(video_get_status() != video_status_closed)
{
    alarm[0] = 1;
    return;
}

// Get the currently selected scene mode.
var _mode = scene_modes[mode];

// Get the requested video.
var _clip = _mode.clips[current_phase];

// Make sure we have a valid video path.
if(_clip == "INVALID" || !file_exists(_clip))
{
    show_debug_message("ERROR: Invalid video: " + string(_clip));
    video_open_pending = false;
    return;
}

// Open the new video.
video = video_open(_clip);
video_open_pending = true;
video_close_pending = false;

// Wait until the new video is actually playing.
if(video_get_status() != video_status_playing)
{
    alarm[3] = 1;
    return;
}

// Video is playing successfully.
video_open_pending = false;
video_last_position = -100;

video_enable_loop(true);
video_set_volume(scr_get_volume(AUDIO_GROUP.SOUND));

event_user(2);