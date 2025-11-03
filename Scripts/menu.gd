extends PanelContainer

@onready var debug_options: PanelContainer = $"../DebugOptions"



func _on_add_button_pressed() -> void:
	
	UnitManager.add_unit()
	

func _on_delete_button_pressed() -> void:
	
	UnitManager.delete_selected_units()


func _on_options_button_pressed() -> void:
	if not debug_options.visible:
		debug_options.show()
	else:
		debug_options.hide()
		
