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