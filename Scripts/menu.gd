extends PanelContainer

@onready var main = $"../../../Main"
@onready var debug_options: PanelContainer = $"../DebugOptions"
@onready var debug_options_window: PanelContainer = $"../../../Main/In Game Menu/Debug Options Menu"


func _on_add_button_pressed() -> void:
	
	main.add_unit()
	

func _on_delete_button_pressed() -> void:
	
	main.delete_selected_units()


func _on_options_button_pressed() -> void:
	if not debug_options_window.visible:
		debug_options_window.show()
	else:
		debug_options_window.hide()
