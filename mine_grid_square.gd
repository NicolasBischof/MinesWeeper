extends GridContainer
class_name MineGridSquare

signal mine_mark_changed(mark_changed_by:int)
signal game_started
signal game_won
signal game_lost(exploded_mine:MineButton)
enum {TOP_LEFT, TOP, TOP_RIGHT, LEFT, RIGHT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT}
var _mine_marks := {"correct":0, "total":0}
var _number_of_mines:int
var _grid_size:Vector2i
var _game_started := false


func _init(grid_size:Vector2i, mines:int) -> void:
	_grid_size = grid_size
	_number_of_mines = mines
	set_columns(_grid_size.x)
	add_theme_constant_override("v_separation", 0)
	add_theme_constant_override("h_separation", 0)
	_create_mine_buttons()


func _create_mine_buttons() -> void:
	for y in _grid_size.y:
		for x in _grid_size.x:
			var button_pos := Vector2i(x, y)
			var mine_button = MineButton.new(button_pos)
			mine_button.pressed_mine_button.connect(_clear_mine)
			mine_button.mine_mark_changed.connect(_register_mine_mark_change)
			add_child(mine_button)


func _get_mine_button(pos:Vector2i) -> MineButton:
	return get_child(pos.x + pos.y * _grid_size.x)


func _load_mines(not_here:Vector2i) -> void:
	var exclude:Array = [not_here]
	exclude.append_array(_get_neighbor_positions(not_here).values())
	var created_mines := 0
	while created_mines < _number_of_mines:
		var new_mine_x := randi() % int(_grid_size.x)
		var new_mine_y := randi() % int(_grid_size.y)
		var new_mine := Vector2i(new_mine_x, new_mine_y)
		if not (new_mine in exclude):
			exclude.append(new_mine)
			_get_mine_button(new_mine).has_mine = true
			created_mines += 1


func _start_game_if(grid_pos:Vector2i) -> void:
	if not _game_started:
		_game_started = true
		_load_mines(grid_pos)
		game_started.emit()


func _get_neighbor_positions(pos:Vector2i) -> Dictionary:
	var x := pos.x
	var y := pos.y
	var neighbors := {}
	if y > 0:
		neighbors[TOP] = Vector2i(x, y-1)
		if x > 0:
			neighbors[TOP_LEFT] = Vector2i(x-1, y-1)
		if  x < _grid_size.x - 1:
			neighbors[TOP_RIGHT] = Vector2i(x+1, y-1)
	if y < _grid_size.y - 1:
		neighbors[BOTTOM] = Vector2i(x, y+1)
		if x > 0:
			neighbors[BOTTOM_LEFT] = Vector2i(x-1, y+1)
		if x < _grid_size.x - 1:
			neighbors[BOTTOM_RIGHT] = Vector2i(x+1, y+1)
	if x > 0:
		neighbors[LEFT] = Vector2i(x-1, y)
	if x < _grid_size.x - 1:
		neighbors[RIGHT] = Vector2i(x+1, y)
	return neighbors


func _get_number_of_adjacent_mines(pos:Vector2i) -> int:
	var number_of_mines := 0
	for n_pos in _get_neighbor_positions(pos).values():
		if _get_mine_button(n_pos).has_mine:
			number_of_mines += 1
	return number_of_mines


func _clear_mine(grid_position:Vector2i) -> void:
	var button := _get_mine_button(grid_position)
	if button.disabled: return
	_start_game_if(grid_position)
	if not button.is_marked_as_mine():
		button.disabled = true
		if button.has_mine:
			return _game_lost(grid_position)
		var adjacent_mines := _get_number_of_adjacent_mines(button.grid_position)
		if adjacent_mines > 0:
			button.text = str(adjacent_mines)
			return
	
	var neighbors:Dictionary = _get_neighbor_positions(button.grid_position)
	var is_contiguous := func is_contiguous(place:int) -> bool:
		match place:
			TOP_LEFT: return LEFT in neighbors or TOP in neighbors
			TOP_RIGHT: return RIGHT in neighbors or TOP in neighbors
			BOTTOM_LEFT: return LEFT in neighbors or BOTTOM in neighbors
			BOTTOM_RIGHT: return RIGHT in neighbors or BOTTOM in neighbors
		return true
	
	for adjacent_place in neighbors.keys():
		var adjacent_mine := _get_mine_button(neighbors[adjacent_place])
		if is_contiguous.call(adjacent_place) and not adjacent_mine.disabled:
			_clear_mine(adjacent_mine.grid_position)


func _register_mine_mark_change(influence:int, has_mine:bool, grid_pos:Vector2i) -> void:
	_start_game_if(grid_pos)
	if has_mine:
		_mine_marks.correct += influence
	_mine_marks.total += influence
	mine_mark_changed.emit(influence)
	if _game_cleared():
		get_tree().call_group("mine buttons", "set_end_of_game_state")
		game_won.emit()


func _game_cleared() -> bool:
	var all_mines_marked:bool = _mine_marks.correct == _number_of_mines
	var extra_mines_marked:bool = _mine_marks.total > _number_of_mines
	return all_mines_marked and not extra_mines_marked


func _game_lost(grid_position:Vector2i) -> void:
	get_tree().call_group(
		"mine buttons",
		"set_end_of_game_state",
		grid_position
	)
	game_lost.emit()
