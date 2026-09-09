/// scr_character_file_parser

function CFP_Tokenize(_text)
{
	_text = string_replace_all(_text, "\r\n", "\n");
	_text = string_replace_all(_text, "\r", "\n");

	var _raw_lines = string_split(_text, "\n");
	var _lines = [];

	for(var _i = 0; _i < array_length(_raw_lines); _i++)
	{
		var _trimmed = string_trim(_raw_lines[_i]);
		if(_trimmed != "")
		{
			array_push(_lines, _trimmed);
		}
	}

	return _lines;
}

function CFP_LineType(_line)
{
	if(string_copy(_line, 1, 2) == "[[")
	{
		var _inner = string_copy(_line, 3, string_length(_line) - 4);
		if(string_char_at(_inner, string_length(_inner)) == ":")
		{
			_inner = string_copy(_inner, 1, string_length(_inner) - 1);
		}
		return { type : "section", name : _inner };
	}

	if(string_copy(_line, 1, 5) == "[end ")
	{
		return { type : "close", name : string_copy(_line, 6, string_length(_line) - 6) };
	}

	if(string_char_at(_line, 1) == "[" && string_char_at(_line, string_length(_line)) == "]")
	{
		return { type : "open", name : string_copy(_line, 2, string_length(_line) - 2) };
	}

	return { type : "text", value : _line };
}

function CFP_IsGenderKeyword(_name)
{
	return (_name == "male" || _name == "female" || _name == "nongendered");
}

function CFP_Peek(_lines, _pos)
{
	if(_pos.i >= array_length(_lines)) { return { type : "eof" }; }
	return CFP_LineType(_lines[_pos.i]);
}

function CFP_Next(_lines, _pos)
{
	var _t = CFP_Peek(_lines, _pos);
	_pos.i++;
	return _t;
}

function CFP_ResolveBlock(_items, _explicit_close)
{
	if(array_length(_items) == 0)
	{
		return _explicit_close ? [] : "";
	}

	if(!_explicit_close && array_length(_items) == 1 && is_string(_items[0]))
	{
		return _items[0]; // a true single-line scalar
	}

	var _all_tags = true;
	var _names = [];

	for(var _i = 0; _i < array_length(_items); _i++)
	{
		if(is_string(_items[_i])) { _all_tags = false; }
		else { array_push(_names, _items[_i].tag); }
	}

	if(_all_tags)
	{
		var _unique = true;
		for(var _i = 0; _i < array_length(_names) && _unique; _i++)
		{
			for(var _j = _i + 1; _j < array_length(_names); _j++)
			{
				if(_names[_i] == _names[_j]) { _unique = false; break; }
			}
		}

		if(_unique)
		{
			var _struct = {};
			for(var _i = 0; _i < array_length(_items); _i++)
			{
				_struct[$ _items[_i].tag] = _items[_i].value;
			}
			return _struct;
		}
	}

	// Either mixed text/tags, or a repeated tag name (e.g. several
	// [mode] blocks) — return as an ordered list either way.
	return _items;
}

function CFP_ParseTagValue(_lines, _pos, _tag_name)
{
	var _is_gender_scope = CFP_IsGenderKeyword(_tag_name);
	var _items = [];
	var _explicit_close = false;

	while(true)
	{
		var _peek = CFP_Peek(_lines, _pos);

		if(_peek.type == "eof" || _peek.type == "section") { break; }

		if(_peek.type == "close")
		{
			if(_peek.name == _tag_name)
			{
				CFP_Next(_lines, _pos);
				_explicit_close = true;
			}
			break; // ours, or an ancestor's — either way, stop here
		}

		if(_peek.type == "open")
		{
			// male/female/nongendered implicitly close each other.
			if(_is_gender_scope && CFP_IsGenderKeyword(_peek.name)) { break; }

			// A single line collected with no [end] seen yet means
			// this tag was actually a scalar — the new tag belongs
			// to whoever contains us.
			if(!_explicit_close && array_length(_items) == 1 && is_string(_items[0])) { break; }

			CFP_Next(_lines, _pos);
			var _child_value = CFP_ParseTagValue(_lines, _pos, _peek.name);
			array_push(_items, { tag : _peek.name, value : _child_value });
			continue;
		}

		array_push(_items, _peek.value);
		CFP_Next(_lines, _pos);
	}

	return CFP_ResolveBlock(_items, _explicit_close);
}

function ParseCharacterFile(_path)
{
	if(!file_exists(_path))
	{
		show_debug_message("ParseCharacterFile: file not found: " + _path);
		return undefined;
	}

	var _buffer = buffer_load(_path);
	var _text = buffer_read(_buffer, buffer_text);
	buffer_delete(_buffer);

	var _lines = CFP_Tokenize(_text);
	var _pos = { i : 0 };
	var _root = {};

	while(_pos.i < array_length(_lines))
	{
		var _peek = CFP_Peek(_lines, _pos);

		if(_peek.type == "section")
		{
			CFP_Next(_lines, _pos);
			_root[$ _peek.name] = CFP_ParseTagValue(_lines, _pos, _peek.name);
		}
		else
		{
			show_debug_message("ParseCharacterFile: ignoring line outside a section.");
			CFP_Next(_lines, _pos);
		}
	}

	return _root;
}