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

		scene_mode_defs      : [],
		raw_parsed           : undefined
	};
}

function LoadCharacterFolder(_key, _folder)
{
	var _config_path = _folder + _key + ".txt";

	if(!file_exists(_config_path))
	{
		show_debug_message("LoadCharacters: skipping \"" + _key + "\" — no " + _key + ".txt found.");
		return undefined;
	}

	var _parsed = ParseCharacterFile(_config_path);
	if(is_undefined(_parsed)) { return undefined; }

	var _char = CharacterData(_key);
	_char.folder_path = _folder;
	_char.raw_parsed = _parsed;

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

	if(variable_struct_exists(_parsed, "Scene Modes"))
	{
		var _mode_values = CFP_ExtractRepeated(_parsed[$ "Scene Modes"], "mode");

		for(var _i = 0; _i < array_length(_mode_values); _i++)
		{
			var _mode_val = _mode_values[_i];

			array_push(_char.scene_mode_defs, {
				name   : variable_struct_exists(_mode_val, "name")   ? _mode_val.name   : "Mode",
				prefix : variable_struct_exists(_mode_val, "prefix") ? _mode_val.prefix : "mode",
				phases : variable_struct_exists(_mode_val, "phases") ? real(_mode_val.phases) : 5,
				icon   : variable_struct_exists(_mode_val, "icon")   ? _mode_val.icon   : ""
			});
		}
	}

	return _char;
}

function LoadCharacters()
{
	global.characters = [];

	var _root = "characters/";

	if(!directory_exists(_root))
	{
		show_debug_message("LoadCharacters: no characters/ folder found.");
		return;
	}

	var _folder_name = file_find_first(_root + "*", fa_directory);

	while(_folder_name != "")
	{
		if(_folder_name != "." && _folder_name != ".."
		&& directory_exists(_root + _folder_name))
		{
			var _char = LoadCharacterFolder(_folder_name, _root + _folder_name + "/");

			if(!is_undefined(_char))
			{
				array_push(global.characters, _char);
			}
		}

		_folder_name = file_find_next();
	}

	file_find_close();

	show_debug_message("LoadCharacters: " + string(array_length(global.characters)) + " character(s) loaded.");
}