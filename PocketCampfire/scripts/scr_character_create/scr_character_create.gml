function CharacterData(_key)
{
	return {
		key                  : _key,
		display_name         : _key,
		folder_path          : "characters/" + _key + "/",

		mon_height           : 0,
		mon_scale            : 1,
		bg_height            : 0,
		menu_offset          : 0,
		berries              : [],
		genders              : "mf",

		scene_mode_defs      : [],  // still to design — new [[Scene Modes:]] section
		raw_parsed           : undefined
	};
}

function LoadCharacterFolder(_key, _folder)
{
	var _config_path = _folder + _key + ".txt";  // matches the old zoroark/zoroark.txt convention

	if(!file_exists(_config_path))
	{
		show_debug_message("LoadCharacters: skipping \"" + _key + "\" — no " + _key + ".txt found.");
		return undefined;
	}

	var _parsed = ParseCharacterFile(_config_path);
	if(is_undefined(_parsed)) { return undefined; }

	var _char = CharacterData(_key);
	_char.folder_path = _folder;
	_char.raw_parsed = _parsed; // Sprites/Localisation/Sounds live here, unconsumed for now

	if(variable_struct_exists(_parsed, "Variables"))
	{
		var _vars = _parsed.Variables;

		if(variable_struct_exists(_vars, "name"))         _char.display_name = _vars.name;
		if(variable_struct_exists(_vars, "mon height"))    _char.mon_height   = real(_vars[$ "mon height"]);
		if(variable_struct_exists(_vars, "mon scale"))     _char.mon_scale    = real(_vars[$ "mon scale"]);
		if(variable_struct_exists(_vars, "bg height"))     _char.bg_height    = real(_vars[$ "bg height"]);
		if(variable_struct_exists(_vars, "menu offset"))   _char.menu_offset  = real(_vars[$ "menu offset"]);
		if(variable_struct_exists(_vars, "gender"))        _char.genders      = _vars.gender;
		if(variable_struct_exists(_vars, "berries"))       _char.berries      = _vars.berries;
	}

	return _char;
}