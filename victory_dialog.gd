extends AcceptDialog

func show_dialog(center:Vector2i, seconds:int) -> void:
	var label:Label = get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "You Won the %s Game\nin %s seconds" % [GameData.size, seconds]
	show()
	position = center - size/2
