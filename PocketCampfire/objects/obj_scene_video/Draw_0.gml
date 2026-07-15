/// Draw Event

// Scene
var _video_data = video_draw();
var _video_status = _video_data[0];

if(_video_status == 0)
{
	shader_set(sh_lut);
	texture_set_stage(lut_sampler, lut_texture);
	draw_surface(_video_data[1], 0, 0);
	shader_reset();
}

// If we're in the cumming or recovery phase, don't draw GUI
if(current_phase >= 3) { return; }

// --------------------------------------------------
// CONTROL BUTTONS
// --------------------------------------------------

for(var _i = 0; _i < button_count; _i++)
{
	var _sprite = selected_button == _i ? button_selected : button;

	var _button_y = button_y + (_i * button_trueheight) + button_margin_y;

	// Add spacing between mode buttons and speed buttons
	if(_i >= mode_count)
	{
		_button_y += button_modebutton_gap;
	}

	var _sprite_index;

	// MODE BUTTONS
	if(_i < mode_count)
	{
		// For now:
		// 0 = Oral
		// 1 = Sex
		// Any extra modes reuse the Oral icon until
		// custom icons are implemented.
		if(_i == 0)
			_sprite_index = 0;
		else if(_i == 1)
		{
			if(gender == GENDERS.M)
				_sprite_index = 2;
			else
				_sprite_index = 1;
		}
		else
		{
			_sprite_index = 0;
		}
	}
	else
	{
		var _phase_button = _i - mode_count;

		switch(_phase_button)
		{
			case 0:
				_sprite_index = 3; // Slow
			break;

			case 1:
				_sprite_index = 4; // Medium
			break;

			case 2:
				_sprite_index = 5; // Fast
			break;

			default:
				_sprite_index = 6; // Finish
			break;
		}
	}

	// Finish button disabled until pleasure full
	if(_i == button_count - 1 && pleasure < 100)
	{
		draw_sprite_ext(
			button,
			_sprite_index,
			button_x,
			_button_y,
			1,
			1,
			0,
			c_white,
			0.6
		);
	}
	else
	{
		draw_sprite(
			_sprite,
			_sprite_index,
			button_x,
			_button_y
		);
	}
}

// --------------------------------------------------
// PLEASURE BAR
// --------------------------------------------------

var _progress = pleasure / 100;

var _progress_y_top =
	pleasure_bar_height -
	pleasure_bar_progress_padding_bottom;

_progress_y_top -= pleasure_bar_trueheight * _progress;

var _progress_height =
	lerp(0, pleasure_bar_trueheight, _progress);

var _scene_progress_y =
	_progress_y_top + pleasure_bar_y;

draw_sprite_part(
	pleasure_bar_progress,
	0,
	0,
	_progress_y_top,
	pleasure_bar_width,
	_progress_height,
	pleasure_bar_x,
	_scene_progress_y
);

draw_sprite(
	pleasure_bar,
	0,
	pleasure_bar_x,
	pleasure_bar_y
);

// --------------------------------------------------
// MENU BUTTONS
// --------------------------------------------------

for(var _i = 0; _i < menubutton_count; _i++)
{
	var _menubutton_x =
		menubutton_x +
		((menubutton_width + menubutton_gap) * _i);

	var _menubutton_index =
		selected_menubutton == _i
		? (_i * 2) + 1
		: (_i * 2);

	var _menubutton_a =
		(!voice_enabled && _i == 2)
		? 0.2
		: 1;

	draw_sprite_ext(
		menubutton,
		_menubutton_index,
		_menubutton_x,
		menubutton_y,
		1,
		1,
		0,
		c_white,
		_menubutton_a
	);
}

// --------------------------------------------------
// FADE
// --------------------------------------------------

draw_set_color(c_white);
draw_set_alpha(fade_a);
draw_rectangle(
	0,
	0,
	global.game_width,
	global.game_height,
	false
);
draw_set_alpha(1);