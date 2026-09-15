function SceneMode(_name, _icon_sprite, _clips)
{
	return {
		name : _name,
		icon_sprite : _icon_sprite,
		clips : _clips
	};
}

mon_species = global.active_mon[? "species"];

lut_sampler = shader_get_sampler_index(sh_lut, "s_Lut");

// State Variables
finished = false;
locked = false;

mode = 0;
target_mode = 0;
target_phase = 0;
current_phase = 0;

// Video Reference Obtaining & Variables
mon_name = global.active_mon[? "name"];
mon_name_file = string_replace_all(string_lower(mon_name), " ", "");

gender = global.active_mon[? "gender"];
gender_string = gender == GENDERS.M ? "m" : "f";

// --------------------------------------------------
// CHARACTER LOOKUP
// --------------------------------------------------

char_data = noone;

for(var _i = 0; _i < array_length(global.characters); _i++)
{
	if(global.characters[_i].key == mon_name_file)
	{
		char_data = global.characters[_i];
		break;
	}
}

if(char_data == noone)
{
	show_debug_message("obj_scene_video: no character data found for \"" + mon_name_file + "\" — scene cannot load modes.");
}

// --------------------------------------------------
// LUT TEXTURE
// --------------------------------------------------

if(is_string(mon_species))
{
	// Modded character: load their own LUT at runtime, falling back
	// to the base game's neutral LUT if they didn't supply one.
	var _lut_path = (char_data != noone) ? char_data.folder_path + "lut.png" : "";
	var _lut_sprite = (_lut_path != "" && file_exists(_lut_path))
		? sprite_add(_lut_path, 1, false, false, 0, 0)
		: spr_scene_lut;
	lut_texture = sprite_get_texture(_lut_sprite, 0);
}
else
{
	// Built-in species: shared strip sprite, one frame per species.
	lut_texture = sprite_get_texture(spr_scene_lut, mon_species + 1);
}

// --------------------------------------------------
// MODE DATA
// --------------------------------------------------

scene_modes = [];

if(char_data != noone)
{
	show_debug_message("==================================");
	show_debug_message("Loading character: " + mon_name_file);

	for(var _i = 0; _i < array_length(char_data.scene_mode_defs); _i++)
	{
		var _def = char_data.scene_mode_defs[_i];
		var _clips = array_create(_def.phases);

		for(var _p = 0; _p < _def.phases; _p++)
		{
			var _clip = char_data.folder_path + mon_name_file + "_" + _def.prefix + "_" + gender_string + "_" + string(_p + 1) + ".mp4";

			show_debug_message("Trying: " + _clip);

			if(!file_exists(_clip))
			{
				show_debug_message("Missing, trying gender-neutral...");
				_clip = char_data.folder_path + mon_name_file + "_" + _def.prefix + "_" + string(_p + 1) + ".mp4";
			}

			show_debug_message("Exists = " + string(file_exists(_clip)));

			_clips[_p] = file_exists(_clip) ? _clip : "INVALID";
		}

		scene_modes[_i] = SceneMode(_def.name, GetModeIcon(_def.name, char_data, _def), _clips);
	}
}

mode_count = array_length(scene_modes);

// --------------------------------------------------
// AUDIO
// --------------------------------------------------

voice_enabled = true;

with(obj_sound_manager)
{
	other.voice_enabled = human_voice_enabled;
}

human_voiceclips =
[
	snd_human_1,
	snd_human_2,
	snd_human_3,
	snd_human_4,
	snd_human_5
];

human_voiceclips_muffled =
[
	snd_humanmuffled_1,
	snd_humanmuffled_2,
	snd_humanmuffled_3,
	snd_humanmuffled_4,
	snd_humanmuffled_5
];

current_humanvoice = -1;
ag_voice_gain = audio_group_get_gain(ag_voice);

// --------------------------------------------------
// VIDEO
// --------------------------------------------------

video = noone;

video_close_pending = false;
video_open_pending = false;
video_close_wait = false;
video_last_position = -100;

event_user(1);

// --------------------------------------------------
// PLEASURE BAR
// --------------------------------------------------

pleasure_bar = spr_scene_pleasurebar;
pleasure_bar_progress = spr_scene_pleasurebar_progress;

pleasure_bar_width = sprite_get_width(pleasure_bar);
pleasure_bar_height = sprite_get_height(pleasure_bar);

pleasure_bar_x = 10;
pleasure_bar_y = global.game_height / 2 - pleasure_bar_height / 2;

pleasure_bar_progress_padding_top = 10;
pleasure_bar_progress_padding_bottom = 15;

pleasure_bar_trueheight =
	pleasure_bar_height
	- pleasure_bar_progress_padding_top
	- pleasure_bar_progress_padding_bottom;

pleasure = 0;
max_pleasure = 100;

// --------------------------------------------------
// CONTROL BUTTONS
// --------------------------------------------------

button = spr_scene_controlbutton;
button_selected = spr_scene_controlbutton_selected;

button_count = mode_count + 4;

button_width = sprite_get_width(button);
button_height = sprite_get_height(button);

button_margin_x = 10;
button_margin_y = 3;

button_modebutton_gap = 20;

button_x = global.game_width - button_margin_x;

button_y =
	global.game_height / 2
	- (button_count * (button_height + button_margin_y * 2)
	+ button_modebutton_gap) / 2;

button_trueheight = button_height + (button_margin_y * 2);

selected_button = -1;

// --------------------------------------------------
// MENU BUTTONS
// --------------------------------------------------

menubutton = spr_scene_menubuttons;

menubutton_count = 3;

menubutton_width = sprite_get_width(menubutton);
menubutton_height = sprite_get_height(menubutton);

menubutton_margin_x = 10;
menubutton_margin_y = 10;

menubutton_x = menubutton_margin_x;
menubutton_y = global.game_height - menubutton_margin_y;

menubutton_gap = 10;

selected_menubutton = -1;

// --------------------------------------------------
// FADING
// --------------------------------------------------

fade_time = 0.1;

fading = false;
fade_dir = 0;
fade_a = 0;

with(obj_sound_manager)
{
	event_user(0);
}