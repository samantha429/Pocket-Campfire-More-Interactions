/// @description Set sprite subimage.

if(is_string(species_id))
{
	// Modded character: use the camp sprite from their own folder
	var _char = GetCharacterByKey(species_id);
	var _camp_sprite = is_undefined(_char) ? noone : GetModdedCampSprite(_char);

	if(_camp_sprite != noone)
	{
		sprite_index = _camp_sprite;
		image_index = 0;
		width = sprite_get_width(sprite_index) * image_yscale;
		height = sprite_get_height(sprite_index) * image_yscale;
	}
}
else
{
	image_index = species_id;
}