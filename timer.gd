extends Timer

@onready var _time_label := get_parent()


func _on_timer_timeout():
	_time_label.number += 1
	if _time_label.number >= 999:
		stop()
