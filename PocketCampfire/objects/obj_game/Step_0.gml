// TEMPORARY - put a Mew in the camp (8 = female, 9 = male)
if(global.game_state == GAME_STATE.CAMP)
{
	if(keyboard_check_pressed(ord("8"))) { scr_create_mon("mew", GENDERS.F); scr_camp_spawn_mon(ds_list_size(global.ds_mon) - 1); }
	if(keyboard_check_pressed(ord("9"))) { scr_create_mon("mew", GENDERS.M); scr_camp_spawn_mon(ds_list_size(global.ds_mon) - 1); }
}