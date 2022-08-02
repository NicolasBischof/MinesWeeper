extends Label
class_name NumberDisplay

@export var _min_size:int = 3
@export var _number:int = 0

var number:int:
	get: return _number
	set(num):
		_number = num
		_update_text()


func _ready() -> void:
	_update_text()


func _update_text() -> void:
	text = str(_number).pad_zeros(_min_size)
