extends PanelContainer

var drag_point = null
@onready var in_game_menu: CanvasLayer = $".."
@onready var graphics: PanelContainer = $"../Graphics"
@onready var debug_options_menu: PanelContainer = $"../Debug Options Menu"


func _on_tb_option_selection_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					
					drag_point = get_global_mouse_position() - get_screen_position()
				elif event.is_released():
					drag_point = null
	
	if event is InputEventMouseMotion and drag_point != null:
		set_position(get_global_mouse_position() - drag_point)

func _on_close_button_pressed() -> void:
	
	in_game_menu.hide()
	self.show()

func _on_graphics_button_pressed() -> void:
	if not graphics.visible:
		graphics.show()
		self.hide()
	else:
		graphics.hide()


func _on_debug_options_button_pressed() -> void:
	if not debug_options_menu.visible:
		debug_options_menu.show()
		self.hide()
	else:
		debug_options_menu.hide()
