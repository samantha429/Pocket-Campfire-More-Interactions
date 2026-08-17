/// Create Event

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
lut_texture = sprite_get_texture(spr_scene_lut, mon_species + 1);

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
// MODE DATA
// --------------------------------------------------

scene_modes = [];

oral_clips = array_create(5);
sex_clips  = array_create(5);

// Where videos are stored
var base_path = "characters/" + mon_name_file + "/";

show_debug_message("==================================");
show_debug_message("Loading character: " + mon_name_file);
show_debug_message("Base path: " + base_path);

for (var i = 0; i < 5; i++)
{
    //--------------------------------------
    // ORAL
    //--------------------------------------

    oral_clips[i] =
        base_path
        + mon_name_file
        + "_oral_"
        + gender_string
        + "_"
        + string(i + 1)
        + ".mp4";

    show_debug_message("Trying: " + oral_clips[i]);

    if (!file_exists(oral_clips[i]))
    {
        show_debug_message("Missing, trying gender-neutral...");

        oral_clips[i] =
            base_path
            + mon_name_file
            + "_oral_"
            + string(i + 1)
            + ".mp4";
    }

    show_debug_message("Exists = " + string(file_exists(oral_clips[i])));

    if (!file_exists(oral_clips[i]))
    {
        oral_clips[i] = "INVALID";
    }

    //--------------------------------------
    // SEX
    //--------------------------------------

    sex_clips[i] =
        base_path
        + mon_name_file
        + "_sex_"
        + gender_string
        + "_"
        + string(i + 1)
        + ".mp4";

    show_debug_message("Trying: " + sex_clips[i]);

    if (!file_exists(sex_clips[i]))
    {
        show_debug_message("Missing, trying gender-neutral...");

        sex_clips[i] =
            base_path
            + mon_name_file
            + "_sex_"
            + string(i + 1)
            + ".mp4";
    }

    show_debug_message("Exists = " + string(file_exists(sex_clips[i])));

    if (!file_exists(sex_clips[i]))
    {
        sex_clips[i] = "INVALID";
    }
}

// Temporary Test mode
var test_clips = array_create(5);

for (var i = 0; i < 5; i++)
{
    test_clips[i] = oral_clips[i];
}

scene_modes[0] = SceneMode(
    "Oral",
    spr_mode_oral,
    oral_clips
);

scene_modes[1] = SceneMode(
    "Sex",
    spr_mode_sex,
    sex_clips
);

scene_modes[2] = SceneMode(
    "Test",
    spr_mode_test,
    test_clips
);

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