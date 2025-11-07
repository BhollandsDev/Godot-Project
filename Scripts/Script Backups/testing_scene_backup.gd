extends PanelContainer

var drag_point = null



func _on_title_bar_pc_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_point = get_global_mouse_position() - get_screen_position()
				print("pressed")
			elif event.is_released():
				print("released")
				drag_point = null
				
	if event is InputEventMouseMotion and drag_point != null:
		set_position(get_global_mouse_position() - drag_point)
