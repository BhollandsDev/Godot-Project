extends PanelContainer


@onready var option_selection: PanelContainer = $"../Option Selection"
@onready var main = $"../../../Main"
@onready var in_game_menu: CanvasLayer = main.get_node("In Game Menu")
var drag_point = null

func _on_tb_graphic_options_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					
					drag_point = get_global_mouse_position() - get_screen_position()
				elif event.is_released():
					drag_point = null
	
	if event is InputEventMouseMotion and drag_point != null:
		set_position(get_global_mouse_position() - drag_point)


func _on_close_button_pressed() -> void:
	self.hide()
	in_game_menu.hide()
	option_selection.show()
	

func _on_fullscreen_cb_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	
	#var main_window_id = 0
	#if toggled_on:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, main_window_id)
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, main_window_id)
