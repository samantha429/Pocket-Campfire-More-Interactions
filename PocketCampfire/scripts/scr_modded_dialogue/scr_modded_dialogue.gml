/// scr_modded_dialogue

function GetAffectionTierIndex(_level)
{
	switch(_level)
	{
		case AFFECTION_LEVEL.NEW:    return 0;
		case AFFECTION_LEVEL.LOW:    return 1;
		case AFFECTION_LEVEL.MEDIUM: return 2;
		case AFFECTION_LEVEL.HIGH:   return 3;
		case AFFECTION_LEVEL.MAX:    return 4;
	}
	return 0;
}

// Pulls every usable line out of a parsed block, whatever shape it came out as.
function CollectPromptLines(_value, _gender_key, _mon_count, _out)
{
	if(is_string(_value))
	{
		if(_value != "") { array_push(_out, _value); }
	}
	else if(is_array(_value))
	{
		for(var _i = 0; _i < array_length(_value); _i++)
		{
			var _item = _value[_i];

			if(is_string(_item))
			{
				if(_item != "") { array_push(_out, _item); }
			}
			else if(is_struct(_item) && variable_struct_exists(_item, "tag") && variable_struct_exists(_item, "value"))
			{
				CollectTaggedPromptLines(_item.tag, _item.value, _gender_key, _mon_count, _out);
			}
		}
	}
	else if(is_struct(_value))
	{
		var _names = variable_struct_get_names(_value);

		for(var _i = 0; _i < array_length(_names); _i++)
		{
			CollectTaggedPromptLines(_names[_i], _value[$ _names[_i]], _gender_key, _mon_count, _out);
		}
	}
}

function CollectTaggedPromptLines(_tag, _value, _gender_key, _mon_count, _out)
{
	if(_tag == "male" || _tag == "female")
	{
		if(_tag == _gender_key) { CollectPromptLines(_value, _gender_key, _mon_count, _out); }
	}
	else if(_tag == "group")
	{
		var _entries = is_array(_value) ? _value : [_value];
		if(array_length(_entries) == 0 || !is_string(_entries[0])) { return; }

		// [group] N: only when enough other mons are around (1 = more than 2 mons, 2 = more than 4)
		var _digits = string_digits(_entries[0]);
		var _n = (_digits == "") ? 1 : real(_digits);

		if(_mon_count > 2 * _n)
		{
			for(var _i = 1; _i < array_length(_entries); _i++)
			{
				if(is_string(_entries[_i]) && _entries[_i] != "") { array_push(_out, _entries[_i]); }
			}
		}
	}
}

// Finds the best block name: exact tier first, then lower tiers, then higher ones.
function FindPromptBlock(_loc, _prefix, _tier_index, _prefer_x)
{
	var _tiers = ["new", "low", "medium", "high", "max"];

	var _order = [_tier_index];
	for(var _t = _tier_index - 1; _t >= 0; _t--) { array_push(_order, _t); }
	for(var _t = _tier_index + 1; _t < 5; _t++)  { array_push(_order, _t); }

	for(var _i = 0; _i < array_length(_order); _i++)
	{
		var _name = _prefix + _tiers[_order[_i]];

		if(_prefer_x && _order[_i] == _tier_index && variable_struct_exists(_loc, _name + " x")) { return _name + " x"; }
		if(variable_struct_exists(_loc, _name)) { return _name; }
	}

	return undefined;
}

// Plain lines for a mod that has no text for this situation.
function GetFallbackPromptLines(_type)
{
	switch(_type)
	{
		case TEXT_PROMPT_TYPE.CHAT:         return ["I spend some time with NAME."];
		case TEXT_PROMPT_TYPE.EXAMINE:      return ["NAME is relaxing at the camp."];
		case TEXT_PROMPT_TYPE.PET:          return ["I give NAME a gentle pat."];
		case TEXT_PROMPT_TYPE.SHOW_OFF:     return ["I ask NAME to show off, and HE_SHE_L obliges."];
		case TEXT_PROMPT_TYPE.GET_INTIMATE: return ["NAME and I share a close moment together."];
		case TEXT_PROMPT_TYPE.SCENE_START:  return ["NAME and I head into the tent together."];
		case TEXT_PROMPT_TYPE.SCENE_END_A:  return ["That was something special..."];
		case TEXT_PROMPT_TYPE.SCENE_END_B:  return ["NAME and I rest for a moment, then head back outside."];
	}
	return ["..."];
}

function GetModdedPromptLines(_species, _type, _affection_level, _arousal_level, _gender, _mon_count)
{
	var _lines = [];
	var _char = GetCharacterByKey(_species);

	if(!is_undefined(_char)
	&& variable_struct_exists(_char.raw_parsed, "Localisation")
	&& is_struct(_char.raw_parsed.Localisation))
	{
		var _loc = _char.raw_parsed.Localisation;
		var _tier = GetAffectionTierIndex(_affection_level);
		var _prefix = "";
		var _prefer_x = false;

		switch(_type)
		{
			case TEXT_PROMPT_TYPE.CHAT:         _prefix = "txt chat ";    break;
			case TEXT_PROMPT_TYPE.EXAMINE:      _prefix = "txt examine "; break;
			case TEXT_PROMPT_TYPE.PET:          _prefix = "txt pet ";     break;
			case TEXT_PROMPT_TYPE.SHOW_OFF:
				_prefix = "txt showoff ";
				_prefer_x = (_arousal_level == AROUSAL_LEVEL.HIGH);
			break;
			case TEXT_PROMPT_TYPE.GET_INTIMATE: _prefix = "txt intimate "; break;
			case TEXT_PROMPT_TYPE.SCENE_START:  _prefix = "txt scene start "; _tier = (_tier == 4) ? 4 : 3; break;
			case TEXT_PROMPT_TYPE.SCENE_END_A:  _prefix = "txt scene end a "; _tier = (_tier == 4) ? 4 : 3; break;
			case TEXT_PROMPT_TYPE.SCENE_END_B:  _prefix = "txt scene end b "; _tier = (_tier == 4) ? 4 : 3; break;
		}

		if(_prefix != "")
		{
			var _block = FindPromptBlock(_loc, _prefix, _tier, _prefer_x);

			if(!is_undefined(_block))
			{
				var _gender_key = (_gender == GENDERS.M) ? "male" : "female";
				CollectPromptLines(_loc[$ _block], _gender_key, _mon_count, _lines);
			}
		}
	}

	// Files store line breaks as the two characters \n
	for(var _i = 0; _i < array_length(_lines); _i++)
	{
		_lines[_i] = string_replace_all(_lines[_i], "\\n", "\n");
	}

	return _lines;
}