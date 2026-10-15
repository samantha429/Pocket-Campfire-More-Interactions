/// scr_modded_audio

// Returns a playable stream for this character's cry, or -1 if there isn't one.
// Falls back to the plain "cry" if the requested variant is missing.
function GetModdedCry(_species, _cry_type)
{
	var _char = GetCharacterByKey(_species);
	if(is_undefined(_char)) { return -1; }

	if(!variable_struct_exists(_char.raw_parsed, "Sounds") || !is_struct(_char.raw_parsed.Sounds)) { return -1; }
	var _sounds = _char.raw_parsed.Sounds;

	var _tag = "cry";
	switch(_cry_type)
	{
		case MON_CRIES.HAPPY:   _tag = "cry happy"; break;
		case MON_CRIES.AROUSED: _tag = "cry x";     break;
		case MON_CRIES.SAD:     _tag = "cry sad";   break;
	}

	var _tags = (_tag == "cry") ? ["cry"] : [_tag, "cry"];

	for(var _i = 0; _i < array_length(_tags); _i++)
	{
		var _t = _tags[_i];

		// Load each file once, then remember the result (including "missing")
		if(!variable_struct_exists(_char.loaded_sounds, _t))
		{
			var _stream = -1;

			if(variable_struct_exists(_sounds, _t) && is_string(_sounds[$ _t]))
			{
				var _path = ResolveCharacterPath(_char, _sounds[$ _t]);

				if(file_exists(_path))
				{
					_stream = audio_create_stream(_path);
if(_stream == -1) { show_debug_message("GetModdedCry: could not create a stream from " + _path); }
				}
				else
				{
					show_debug_message("GetModdedCry: missing file for \"" + _char.key + "\": " + _path);
				}
			}

			_char.loaded_sounds[$ _t] = _stream;
		}

		if(_char.loaded_sounds[$ _t] != -1) { return _char.loaded_sounds[$ _t]; }
	}

	return -1;
}