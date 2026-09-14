/// scr_get_mode_icon
function GetModeIcon(_mode_name, _char, _mode_def)
{
	if(_mode_def.icon != "")
	{
		var _icon_path = _char.folder_path + _mode_def.icon;

		if(file_exists(_icon_path))
		{
			return sprite_add(_icon_path, 1, false, false, 0, 0);
		}
	}

	switch(string_lower(_mode_name))
	{
		case "oral": return spr_mode_oral;
		case "sex":  return spr_mode_sex;
		case "test": return spr_mode_test;
	}

	return spr_mode_default;
}