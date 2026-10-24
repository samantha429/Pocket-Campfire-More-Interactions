function scr_get_species_name(argument0)
{
	// Modded characters are identified by a string key
	if(is_string(argument0))
	{
		var _char = GetCharacterByKey(argument0);
		return is_undefined(_char) ? "" : _char.display_name;
	}

	switch(argument0)
	{
		case SPECIES.NICKIT:
			return "Nickit";
		case SPECIES.VULPIX:
			return "Vulpix";
		case SPECIES.ALOLANVULPIX:
			return "Alolan Vulpix";
		case SPECIES.LUCARIO:
			return "Lucario";
		case SPECIES.CINDERACE:
			return "Cinderace";
		case SPECIES.BRAIXEN:
			return "Braixen";
		case SPECIES.ZOROARK:
			return "Zoroark";
		default:
			return "";
	}
}