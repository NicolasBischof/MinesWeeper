extends Node2D


const UI_MARGIN := 10
var mine_grid
@onready var interfase_container := %InterfaseContainer
@onready var rows := %Rows
@onready var board := %Board
@onready var mine_counter := %MineCounter
@onready var time_elapsed := %TimeElapsed
@onready var timer := %TimeElapsed/Timer
@onready var change_size_button := %ChangeSizeButton
@onready var change_type_button := %ChangeTypeButton
@onready var change_size_popup := %ChangeSizePopup
@onready var change_type_popup := %ChangeTypePopup
@onready var victory_dialog := %VictoryDialog
@onready var square_grid_container := %SquareGridContainer


func _ready() -> void:
	setup_mine_grid()
	mine_counter.number = GameData.mines
	call_deferred("_setup_sizes")


func setup_mine_grid() -> void:
	if GameData.game_is_square():
		mine_grid = MineGridSquare.new(GameData.dimensions, GameData.mines)
		square_grid_container.add_child(mine_grid)
	else:
		square_grid_container.queue_free()
		mine_grid = load("res://mine_grid_hexagonal.tscn").instantiate()
		add_child(mine_grid)
	mine_grid.mine_mark_changed.connect(_change_mine_counter)
	mine_grid.game_started.connect(timer.start)
	mine_grid.game_won.connect(_game_won)
	mine_grid.game_lost.connect(timer.stop)


func _setup_sizes() -> void:
	if GameData.game_is_square():
		_set_window_size(interfase_container.size)
	else:
		_setup_interfase_for_hexagonal_grid()


func _set_window_size(size:Vector2i) -> void:
	if size != DisplayServer.window_get_size():
		visible = false
		await get_tree().process_frame
		await get_tree().process_frame
		DisplayServer.window_set_size(size)
		visible = true


func _setup_interfase_for_hexagonal_grid() -> void:
	var grid_size:Vector2i = mine_grid.get_dimensions()
	var interfase_size_x:int = interfase_container.size.x
	mine_grid.position.y = rows.size.y + grid_size.y / 2.0 -5
	var window_width:int
	var window_height:int = rows.size.y + UI_MARGIN*2 + grid_size.y
	var interfase_too_sort := interfase_size_x < grid_size.x + UI_MARGIN*2
	if interfase_too_sort:
		mine_grid.position.x = UI_MARGIN
		interfase_container.size.x = grid_size.x + UI_MARGIN*2
		window_width = UI_MARGIN*2 + grid_size.x
	else:
		mine_grid.position.x = interfase_size_x/2 - grid_size.x/2
		window_width = interfase_size_x
	_set_window_size(Vector2i(window_width, window_height + 4))


func _game_won() -> void:
	timer.stop()
	var dialog_center := DisplayServer.window_get_size() / 2
	dialog_center += Vector2i(0, board.size.y/2 + UI_MARGIN/2)
	victory_dialog.show_dialog(dialog_center, time_elapsed.number)


func _change_mine_counter(mark_changed_by:int) -> void:
	mine_counter.number += mark_changed_by * -1


func _on_change_size_popup_id_pressed(id:int) -> void:
	if not change_size_popup.is_item_checked(id):
		GameData.game_id = id
		reload_scene()


func _on_change_type_popup_id_pressed(id:int) -> void:
	if not change_type_popup.is_item_checked(id):
		GameData.game_type = id
		reload_scene()


func show_change_size_popup() -> void:
	change_size_popup.show()
	if change_size_popup.position == Vector2i.ZERO:
		change_size_popup.setup_position(change_size_button)


func show_change_type_popup() -> void:
	change_type_popup.show()
	if change_type_popup.position == Vector2i.ZERO:
		change_type_popup.setup_position(change_type_button)


func reload_scene() -> void:
	get_tree().reload_current_scene()


