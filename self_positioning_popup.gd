extends PopupMenu
class_name SelfPositioningPopup

func setup_position(button:Button) -> void:
	var button_pos:Vector2i = button.position
	var bottom_button_y:int = button_pos.y + button.size.y
	var center_button_x:int = button_pos.x + button.size.x/2
	var popup_x:int = center_button_x - size.x/2 + 10
	position = Vector2i(popup_x, bottom_button_y + 8)
