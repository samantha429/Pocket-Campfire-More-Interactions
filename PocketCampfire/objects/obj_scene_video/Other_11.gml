///@description Start new video

if(!video_open_pending || video_get_status() == video_status_closed)
{
	var _mode = scene_modes[mode];

video = video_open(
    _mode.clips[current_phase]
);
	video_close_pending = false;
	video_open_pending = true;
}

if(video_get_status() != video_status_playing)
{
	alarm[3] = 1; // Retry after 1 frame
	return;
}
else
{
	video_open_pending = false;
	video_last_position = -100;

	// Select and play a clip
	video_enable_loop(true);
	video_set_volume(scr_get_volume(AUDIO_GROUP.SOUND));

	// Play human voice
	event_user(2);
}