extends TileMap

signal mine_mark_changed(mark_changed_by:int)
signal game_started
signal game_won
signal game_lost(exploded_mine:Vector2i)

const UNTOUCHED_MINE_ATLAS_COORD := Vector2i(0, 0)
const CLEARED_MINE_ATLAS_COORD := Vector2i(1, 0)
const EXPLODED_MINE_ATLAS_COORD := Vector2i(2, 0)

var _mines := {}
var _game_started := false
var _game_ended := false
var _mine_marks := {"correct":0, "total":0}


func _ready():
	cell_quadrant_size = Const.hexagonal_mine_maximal_diameter
	tile_set.tile_size = Vector2i(
		Const.hexagonal_mine_maximal_diameter,
		Const.hexagonal_mine_maximal_diameter
	)
	build_grid()


func _all_mines_marked_no_extras() -> bool:
	var equal_total_and_correct:bool = _mine_marks.total == _mine_marks.correct
	var equal_correct_and_needed:bool = _mine_marks.correct == GameData.mines
	return equal_total_and_correct and equal_correct_and_needed


func set_mine_cell(grid_coord, atlas_coord) -> void:
	set_cell(0, grid_coord, 0, atlas_coord)

	
func _cell_is_valid(cell:Vector2i) -> bool:
	return get_cell_atlas_coords(0, cell, false) != Vector2i(-1, -1)


func _cell_is_clear(cell:Vector2i) -> bool:
	return get_cell_atlas_coords(0, cell, false) == CLEARED_MINE_ATLAS_COORD


func _cell_is_untouched(cell:Vector2i) -> bool:
	var untouched_style := get_cell_atlas_coords(0, cell, false) == UNTOUCHED_MINE_ATLAS_COORD
	return untouched_style and _mines[cell].label.text == ""


func _cell_is_loaded(cell:Vector2i) -> bool:
	return _mines[cell].loaded
	

func _cell_is_unloaded(cell:Vector2i) -> bool:
	return not _cell_is_loaded(cell)


func _cell_is_marked(cell:Vector2i) -> bool:
	return _mines[cell].label.text == Const.mine_mark_char


func _paint_label(label:Label, color:Color) -> void:
	label.add_theme_color_override("font_color", color)


func _input(event):
	if _game_ended: return
	if event is InputEventMouseButton and not event.pressed:
		_process_mine_interaction(event)


func _process_mine_interaction(event:InputEventMouseButton) -> void:
	var cell := world_to_map(event.position - position)
	if _cell_is_clear(cell): return
	if not _cell_is_valid(cell): return
	if not _game_started:
		_load_mines(cell)
		game_started.emit()
		_game_started = true
	if event.button_index == MOUSE_BUTTON_LEFT:
		if _cell_is_untouched(cell):
			_clear_cell(cell)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if _cell_is_marked(cell):
			_unmark_cell(cell)
		else:
			_mark_cell(cell)
		_check_for_victory()


func build_grid() -> void:
	
	var label_offset := Vector2(-5,-11)
	var add_label_and_mine_data := func (cell:Vector2i):
		var label := Label.new()
		_mines[cell] = {"label": label, "loaded": false}
		add_child(label)
		label.position = map_to_world(cell) + label_offset
	
	for center_cell in GameData.maximal_radius:
		var cell := Vector2i(center_cell, 0)
		set_mine_cell(cell, UNTOUCHED_MINE_ATLAS_COORD)
		add_label_and_mine_data.call(cell)
	var x_offset := 0
	
	for y_pos in range(1, int(ceil(GameData.maximal_radius/2.0))):
		var interleave:bool = y_pos % 2 == 0 and y_pos != 0
		var interleaved_int := int(not interleave)
		x_offset += int(interleave)
		var towards_a_point := ceil(GameData.maximal_radius/2.0) - x_offset*2 - interleaved_int
		for x_pos in towards_a_point + GameData.maximal_radius/2:
			var top_cell := Vector2i(x_offset + x_pos, y_pos)
			var bottom_cell := Vector2i(x_offset + x_pos, -y_pos)
			set_mine_cell(top_cell, UNTOUCHED_MINE_ATLAS_COORD)
			set_mine_cell(bottom_cell, UNTOUCHED_MINE_ATLAS_COORD)
			add_label_and_mine_data.call(top_cell)
			add_label_and_mine_data.call(bottom_cell)


func get_dimensions() -> Vector2i:
	var width := Const.hexagonal_mine_maximal_diameter * GameData.maximal_radius
	var height :=  width - GameData.maximal_radius * 8 # hexagon.spike_depth
	return Vector2i(width, height)


func _load_mines(not_here:Vector2i) -> void:
	var exclude:Array[Vector2i] = [not_here]
	exclude.append_array(get_surrounding_tiles(not_here))
	var created_mines := 0
	var radius_aprox := ceil(Const.hexagonal_mine_maximal_diameter / 2.0)
	while created_mines < GameData.mines:
		var new_mine_x := randi_range(0, Const.hexagonal_mine_maximal_diameter)
		var new_mine_y := randi_range(-radius_aprox, radius_aprox)
		var new_mine := Vector2i(new_mine_x, new_mine_y)
		if new_mine in _mines and not _cell_is_loaded(new_mine) and not (new_mine in exclude):
			var mine:Dictionary = _mines[new_mine]
			mine.loaded = true
			created_mines += 1


func _clear_cell(cell:Vector2i) -> void:
	if _cell_is_clear(cell): return
	if _cell_is_loaded(cell): return _game_over(cell)
	var surrounding_tiles := get_surrounding_tiles(cell).filter(_cell_is_valid)
	var empty_mines := surrounding_tiles.filter(_cell_is_unloaded)
	var num_mines := len(surrounding_tiles) - len(empty_mines)
	if not _cell_is_marked(cell):
		set_mine_cell(cell, CLEARED_MINE_ATLAS_COORD)
		if num_mines: _mines[cell].label.text = str(num_mines)
	if num_mines: return
	for unloaded_mine in empty_mines:
		_clear_cell(unloaded_mine)


func _mark_cell(cell:Vector2i) -> void:
	var mine:Dictionary = _mines[cell]
	mine.label.position.x += Const.mine_mark_x_offset
	mine.label.text = Const.mine_mark_char
	_paint_label(mine.label, Const.mine_mark_color)
	_mine_marks.correct += int(_cell_is_loaded(cell))
	_mine_marks.total += 1
	mine_mark_changed.emit(1)


func _unmark_cell(cell:Vector2i) -> void:
	var mine:Dictionary = _mines[cell]
	mine.label.text = ""
	mine.label.position.x -= Const.mine_mark_x_offset
	_paint_label(mine.label, Const.number_font_color)
	_mine_marks.correct -= int(_cell_is_loaded(cell))
	_mine_marks.total -= 1
	mine_mark_changed.emit(-1)


func _check_for_victory() -> void:
	if _all_mines_marked_no_extras():
		_game_ended = true
		game_won.emit()


func _game_over(cell:Vector2i) -> void:
	_game_ended = true
	_game_over_reveal(cell)
	game_lost.emit()


func _game_over_reveal(exploded_cell:Vector2i) -> void:
	set_mine_cell(exploded_cell, EXPLODED_MINE_ATLAS_COORD)
	var exploded_label:Label = _mines[exploded_cell].label
	exploded_label.text = Const.mine_char
	_paint_label(exploded_label, Const.mine_exploded_font_color)
	for cell in _mines.keys():
		var mine:Dictionary = _mines[cell]
		if _cell_is_loaded(cell) and cell != exploded_cell:
			if _cell_is_untouched(cell):
				set_mine_cell(cell, CLEARED_MINE_ATLAS_COORD)
				_paint_label(mine.label, Const.mine_undiscovered_font_color)
			else:
				mine.label.position.x -= Const.mine_mark_x_offset
			mine.label.text = Const.mine_char
		elif mine.label.text == Const.mine_mark_char:
			_paint_label(mine.label, Const.mine_incorrectly_marked_color)
			
			
			
			
