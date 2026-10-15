/// scr_character_sprites

// Turns a path written in a character's .txt into a real file path inside the
// character's folder. Old mods write "mew\female\spr_new.png" (key first);
// the key can also be left off. Both work.
function ResolveCharacterPath(_char, _raw_path)
{
	var _path = string_replace_all(string_trim(_raw_path), "\\", "/");
	var _segments = string_split(_path, "/", true);

	if(array_length(_segments) > 1 && string_lower(_segments[0]) == string_lower(_char.key))
	{
		array_delete(_segments, 0, 1);
	}

	var _relative = "";
	for(var _i = 0; _i < array_length(_segments); _i++)
	{
		_relative += (_i > 0 ? "/" : "") + _segments[_i];
	}

	return _char.folder_path + _relative;
}

// One image file -> a fresh single-frame sprite. Returns noone if missing.
function LoadCharacterImage(_char, _raw_path)
{
	if(!is_string(_raw_path) || _raw_path == "") { return noone; }

	var _full_path = ResolveCharacterPath(_char, _raw_path);

	if(!file_exists(_full_path))
	{
		show_debug_message("LoadCharacterImage: missing file for \"" + _char.key + "\": " + _full_path);
		return noone;
	}

	return sprite_add(_full_path, 1, false, false, 0, 0);
}

// Cached version, for one-off images such as the camp sprite.
function GetCharacterSprite(_char, _raw_path)
{
	if(!is_string(_raw_path) || _raw_path == "") { return noone; }

	if(variable_struct_exists(_char.loaded_sprites, _raw_path))
	{
		return _char.loaded_sprites[$ _raw_path];
	}

	var _sprite = LoadCharacterImage(_char, _raw_path);
	_char.loaded_sprites[$ _raw_path] = _sprite;
	return _sprite;
}

// Tag names in the same order as the SPRITE_MODES enum.
function GetSpriteTagOrder()
{
	return [
		"spr interact new",            // SHY_NEUTRAL
		"spr interact new happy",      // SHY_HAPPY
		"spr interact new angry",      // SHY_UPSET
		"spr interact",                // FRIENDLY_NEUTRAL
		"spr interact x cover",        // FRIENDLY_NEUTRAL_X_COVER
		"spr interact x",              // FRIENDLY_NEUTRAL_X
		"spr interact happy",          // FRIENDLY_HAPPY
		"spr interact happy x cover",  // FRIENDLY_HAPPY_X_COVER
		"spr interact happy x",        // FRIENDLY_HAPPY_X
		"spr interact angry",          // FRIENDLY_UPSET
		"spr showoff",                 // FRIENDLY_SHOWOFF
		"spr showoff x",               // FRIENDLY_SHOWOFF_X
		"spr play 1",                  // FRIENDLY_INTIMATE
		"spr play 2",                  // FRIENDLY_INTIMATE_CUM
		"spr interact max",            // LOVE_NEUTRAL
		"spr interact max x",          // LOVE_NEUTRAL_X
		"spr interact max happy",      // LOVE_HAPPY
		"spr interact max happy x",    // LOVE_HAPPY_X
		"spr interact max angry",      // LOVE_UPSET
		"spr showoff max",             // LOVE_SHOWOFF
		"spr showoff max x",           // LOVE_SHOWOFF_X
		"spr play max 1",              // LOVE_INTIMATE
		"spr play max 2"               // LOVE_INTIMATE_CUM
	];
}

// Builds one 23-frame strip (frame order = SPRITE_MODES) from a gender block.
function BuildInteractionSprite(_char, _block)
{
	var _tags = GetSpriteTagOrder();
	var _count = array_length(_tags);

	// If a state has no image, use this mode instead (-1 = nothing left to try).
	var _fallback = [3, 0, 0, -1, 5, 3, 3, 8, 6, 3, 3, 10, 3, 12, 3, 14, 14, 16, 14, 14, 19, 14, 21];

	// Load every image the mod supplied
	var _loaded = array_create(_count, noone);
	var _first_available = noone;

	for(var _i = 0; _i < _count; _i++)
	{
		if(variable_struct_exists(_block, _tags[_i]))
		{
			_loaded[_i] = LoadCharacterImage(_char, _block[$ _tags[_i]]);

			if(_loaded[_i] != noone && _first_available == noone)
			{
				_first_available = _loaded[_i];
			}
		}
	}

	if(_first_available == noone)
	{
		show_debug_message("BuildInteractionSprite: no usable images for \"" + _char.key + "\".");
		return noone;
	}

	// Choose the image for each slot, following the fallback chain for gaps
	var _slot = array_create(_count, noone);

	for(var _i = 0; _i < _count; _i++)
	{
		var _j = _i;
		var _steps = 0;

		while(_j != -1 && _steps < _count)
		{
			if(_loaded[_j] != noone)
			{
				_slot[_i] = _loaded[_j];
				break;
			}
			_j = _fallback[_j];
			_steps++;
		}

		if(_slot[_i] == noone) { _slot[_i] = _first_available; }
	}

	// Merge into one strip. Copy the first frame so the originals stay untouched.
	var _strip = sprite_duplicate(_slot[0]);
	var _w = sprite_get_width(_strip);
	var _h = sprite_get_height(_strip);

	for(var _i = 1; _i < _count; _i++)
	{
		var _sw = sprite_get_width(_slot[_i]);
		var _sh = sprite_get_height(_slot[_i]);

		if(_sw != _w || _sh != _h)
		{
			show_debug_message("BuildInteractionSprite: \"" + _tags[_i] + "\" for \"" + _char.key + "\" is "
				+ string(_sw) + "x" + string(_sh) + ", expected " + string(_w) + "x" + string(_h) + " - it will be stretched.");
		}

		sprite_merge(_strip, _slot[_i]);
	}

	// Use the same origin convention as the built-in interaction sprites
	var _ref = spr_zoroark_f_interaction;
	sprite_set_offset(
		_strip,
		_w * (sprite_get_xoffset(_ref) / sprite_get_width(_ref)),
		_h * (sprite_get_yoffset(_ref) / sprite_get_height(_ref))
	);

	// The strip holds its own copy of every frame, so free the loose ones
	for(var _i = 0; _i < _count; _i++)
	{
		if(_loaded[_i] != noone && sprite_exists(_loaded[_i])) { sprite_delete(_loaded[_i]); }
	}

	return _strip;
}

function GetModdedInteractionSprite(_char, _gender)
{
	var _gender_key = (_gender == GENDERS.M) ? "male" : "female";
	var _cache_key = "interaction " + _gender_key;

	if(variable_struct_exists(_char.loaded_sprites, _cache_key))
	{
		return _char.loaded_sprites[$ _cache_key];
	}

	var _result = noone;

	if(variable_struct_exists(_char.raw_parsed, "Sprites") && is_struct(_char.raw_parsed.Sprites))
	{
		var _sprites = _char.raw_parsed.Sprites;
		var _other_key = (_gender_key == "male") ? "female" : "male";
		var _block = undefined;

		// Use the right gender's images, or the other gender's if the mod only made one
		if(variable_struct_exists(_sprites, _gender_key) && is_struct(_sprites[$ _gender_key]))
		{
			_block = _sprites[$ _gender_key];
		}
		else if(variable_struct_exists(_sprites, _other_key) && is_struct(_sprites[$ _other_key]))
		{
			_block = _sprites[$ _other_key];
		}

		if(is_struct(_block)) { _result = BuildInteractionSprite(_char, _block); }
	}

	_char.loaded_sprites[$ _cache_key] = _result;
	return _result;
}

function GetModdedCampSprite(_char)
{
	if(variable_struct_exists(_char.loaded_sprites, "camp")) { return _char.loaded_sprites[$ "camp"]; }

	var _result = noone;

	if(variable_struct_exists(_char.raw_parsed, "Sprites") && is_struct(_char.raw_parsed.Sprites)
	&& variable_struct_exists(_char.raw_parsed.Sprites, "spr camp"))
	{
		_result = LoadCharacterImage(_char, _char.raw_parsed.Sprites[$ "spr camp"]);

		if(_result != noone)
		{
			var _w = sprite_get_width(_result);
			var _h = sprite_get_height(_result);
			var _ref = object_get_sprite(obj_camp_mon);

			if(sprite_exists(_ref))
			{
				sprite_set_offset(
					_result,
					_w * (sprite_get_xoffset(_ref) / sprite_get_width(_ref)),
					_h * (sprite_get_yoffset(_ref) / sprite_get_height(_ref))
				);

				show_debug_message("camp sprite for \"" + _char.key + "\": " + string(_w) + "x" + string(_h)
					+ " (built-in: " + string(sprite_get_width(_ref)) + "x" + string(sprite_get_height(_ref)) + ")");
			}
		}
	}

	_char.loaded_sprites[$ "camp"] = _result;
	return _result;
}