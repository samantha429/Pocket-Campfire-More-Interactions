/// scr_character_lookup

// Folder key for each built-in species. Pass integers only.
function GetBuiltinSpeciesKey(_species)
{
	switch(_species)
	{
		case SPECIES.NICKIT:       return "nickit";
		case SPECIES.VULPIX:       return "vulpix";
		case SPECIES.ALOLANVULPIX: return "alolanvulpix";
		case SPECIES.LUCARIO:      return "lucario";
		case SPECIES.CINDERACE:    return "cinderace";
		case SPECIES.BRAIXEN:      return "braixen";
		case SPECIES.ZOROARK:      return "zoroark";
	}
	return undefined;
}

// Built-in keys map back to their SPECIES number; anything else stays a string.
function GetSpeciesFromKey(_key)
{
	for(var _s = 0; _s < SPECIES.AMOUNT; _s++)
	{
		if(GetBuiltinSpeciesKey(_s) == _key) return _s;
	}
	return _key;
}

function GetCharacterByKey(_key)
{
	for(var _i = 0; _i < array_length(global.characters); _i++)
	{
		if(global.characters[_i].key == _key) return global.characters[_i];
	}
	return undefined;
}

// Works for both built-in (number) and modded (string) species.
function GetCharacterForSpecies(_species)
{
	var _key = is_string(_species) ? _species : GetBuiltinSpeciesKey(_species);
	if(is_undefined(_key)) return undefined;
	return GetCharacterByKey(_key);
}

// Every species that can appear: it has a loaded character folder, so it has scenes.
function GetSpawnableSpecies()
{
	var _out = [];
	for(var _i = 0; _i < array_length(global.characters); _i++)
	{
		array_push(_out, GetSpeciesFromKey(global.characters[_i].key));
	}
	return _out;
}

// Placement stats: built-ins keep the hard-coded maps, modded characters use their .txt values.
function GetMonHeight(_species)
{
	if(is_string(_species))
	{
		var _c = GetCharacterForSpecies(_species);
		return is_undefined(_c) ? 0 : _c.mon_height;
	}
	return global.mon_height[? _species];
}

function GetMonScale(_species)
{
	if(is_string(_species))
	{
		var _c = GetCharacterForSpecies(_species);
		return is_undefined(_c) ? 1 : _c.mon_scale;
	}
	return global.mon_scale[? _species];
}

function GetMonBgHeight(_species)
{
	if(is_string(_species))
	{
		var _c = GetCharacterForSpecies(_species);
		return is_undefined(_c) ? 0 : _c.bg_height;
	}
	return global.interact_bg_height[? _species];
}

function SameSpecies(_a, _b)
{
	// Numbers and strings never match each other
	return is_string(_a) == is_string(_b) && _a == _b;
}

function GetBerryName(_item)
{
	switch(_item)
	{
		case ITEM.ORAN_BERRY:   return "oran";
		case ITEM.CHERI_BERRY:  return "cheri";
		case ITEM.COLBUR_BERRY: return "colbur";
		case ITEM.KEBIA_BERRY:  return "kebia";
		case ITEM.BELUE_BERRY:  return "belue";
		case ITEM.PECHA_BERRY:  return "pecha";
		case ITEM.SITRUS_BERRY: return "sitrus";
		case ITEM.QUALOT_BERRY: return "qualot";
		case ITEM.ENIGMA_BERRY: return "enigma";
	}
	return "";
}

function CharacterLikesBerry(_char, _berry_name)
{
	for(var _i = 0; _i < array_length(_char.berries); _i++)
	{
		var _entry = string_lower(string_trim(string(_char.berries[_i])));
		_entry = string_replace(_entry, " berry", "");
		_entry = string_replace(_entry, "_berry", "");

		if(_entry == _berry_name) { return true; }
	}
	return false;
}