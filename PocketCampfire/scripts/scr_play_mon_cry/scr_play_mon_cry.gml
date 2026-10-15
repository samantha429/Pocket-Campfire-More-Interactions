/// @function play_mon_cry(species, cry_type);

function scr_play_mon_cry(_species, _cry_type)
{
	// Modded characters are identified by a string key
	if(is_string(_species))
	{
		var _cry = GetModdedCry(_species, _cry_type);

		if(_cry != -1)
		{
			var _instance = audio_play_sound(_cry, 200, false);

			// Streamed files aren't in an audio group, so copy the volume of
			// the group the built-in cries use
			audio_sound_gain(_instance, audio_group_get_gain(audio_sound_get_audio_group(snd_zoroark_default)), 0);
		}
		return;
	}

	with(obj_sound_manager)
	{
		var _cry_map = mon_cries[? _species];
		var _cry_sound = _cry_map[? _cry_type];
		audio_play_sound(_cry_sound, 200, false);
	}
}