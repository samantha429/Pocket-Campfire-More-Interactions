/// @description Start New Video

// --------------------------------------------------
// A VIDEO IS ALREADY BEING OPENED
// --------------------------------------------------
if(video_open_pending)
{
    // Still loading? Retry next frame.
    if(video_get_status() != video_status_playing)
    {
        alarm[3] = 1;
        return;
    }

    // New video is now playing.
    video_open_pending = false;
    video_last_position = -100;

    video_enable_loop(true);
    video_set_volume(scr_get_volume(AUDIO_GROUP.SOUND));

    event_user(2);
    return;
}


// --------------------------------------------------
// OLD VIDEO MUST BE CLOSED BEFORE OPENING A NEW ONE
// --------------------------------------------------
if(video_get_status() != video_status_closed)
{
    event_user(0);
    return;
}


// --------------------------------------------------
// GET VIDEO PATH
// --------------------------------------------------
var _mode = scene_modes[mode];

// A mode with fewer than 5 phases has no clip for the cum/afterglow
// phases (3 and 4). Log it instead of crashing on an out-of-range index.
if(current_phase >= array_length(_mode.clips))
{
    show_debug_message(
        "ERROR: mode \"" + _mode.name + "\" has no clip for phase " + string(current_phase)
    );

    video_open_pending = false;
    return;
}

var _clip = _mode.clips[current_phase];

show_debug_message(
    "Opening video: " + string(_clip)
);


// --------------------------------------------------
// INVALID VIDEO CHECK
// --------------------------------------------------
if(_clip == "INVALID" || !file_exists(_clip))
{
    show_debug_message(
        "ERROR: Invalid video: " + string(_clip)
    );

    video_open_pending = false;
    return;
}


// --------------------------------------------------
// OPEN NEW VIDEO
// --------------------------------------------------
video = video_open(_clip);

video_close_pending = false;
video_open_pending = true;


// The video opens asynchronously.
// Alarm 3 will call this event again until it is playing.
alarm[3] = 1;