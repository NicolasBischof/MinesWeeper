extends Button
class_name MineButton

signal pressed_mine_button(button:MineButton)
signal mine_mark_changed(influence:int, has_mine:bool, grid_pos:Vector2i)
const _button_size := Vector2i(Const.square_mine_size, Const.square_mine_size)
var grid_position:Vector2i
var has_mine := false
var _input_disabled := false


func _init(grid_pos:Vector2i) -> void:
	focus_mode = Control.FOCUS_NONE
	add_theme_stylebox_override("disabled", Const.mine_btn_disabled_style)
	add_theme_stylebox_override("normal", Const.mine_btn_normal_style)
	add_theme_color_override("font_disabled_color", Const.number_font_color)
	grid_position = grid_pos
	custom_minimum_size = _button_size
	size = _button_size
	add_to_group("mine buttons")
	gui_input.connect(_on_button_input)


func is_marked_as_mine() -> bool:
	return self.text == Const.mine_mark_char

func is_marked_as_mine_correctly() -> bool:
	return is_marked_as_mine() and has_mine

func is_marked_as_mine_incorrectly() -> bool:
	return is_marked_as_mine() and not has_mine

func is_untouched() -> bool:
	return not disabled and text == ""


func _on_button_input(event) -> void:
	if disabled or _input_disabled: return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT: _left_click()
			MOUSE_BUTTON_RIGHT: _right_click()


func _left_click() -> void:
	if not is_marked_as_mine():
		pressed_mine_button.emit(grid_position)


func _right_click() -> void:
	if is_untouched():
		_mark_mine()
	else:
		_unmark_mine()


func _mark_mine() -> void:
	text = Const.mine_mark_char
	_set_text_color(Const.mine_mark_color)
	mine_mark_changed.emit(1, has_mine, grid_position)


func _unmark_mine() -> void:
	text = ""
	_set_text_color(Const.number_font_color)
	mine_mark_changed.emit(-1, has_mine, grid_position)


func _set_text_color(color:Color) -> void:
	add_theme_color_override("font_color", color)
	add_theme_color_override("font_hover_color", color)
	add_theme_color_override("font_disabled_color", color)


func set_end_of_game_state(exploding_grid_position:Vector2i = Vector2i(-1, -1)) -> void:
	_input_disabled = true
	if has_mine:
		if grid_position == exploding_grid_position:
			_style_as_exploding_mine()
		elif is_untouched():
			disabled = true
			_style_as_revealed_mine()
		text = Const.mine_char
	elif is_marked_as_mine_incorrectly():
		_style_as_incorrectly_marked()


func _style_as_exploding_mine() -> void:
	add_theme_stylebox_override("disabled", Const.mine_btn_exploded_style)
	_set_text_color(Const.mine_exploded_font_color)

func _style_as_revealed_mine() -> void:
	_set_text_color(Const.mine_undiscovered_font_color)

func _style_as_incorrectly_marked() -> void:
	_set_text_color(Const.mine_incorrectly_marked_color)
