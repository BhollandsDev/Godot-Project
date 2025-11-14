extends PanelContainer

@onready var main = $"../../../Main"

@onready var debug_options_window: PanelContainer = $"../../../Main/In Game Menu/Debug Options Menu"
@onready var selection_manager := get_tree().get_first_node_in_group("Selection Manager")
@onready var mine_button: Button = $"MarginContainer/Container/Mine button"

func _on_add_button_pressed() -> void:
	
	main.add_unit()
	

func _on_delete_button_pressed() -> void:
	
	main.delete_selected_units()


func _on_options_button_pressed() -> void:
	if not debug_options_window.visible:
		debug_options_window.show()
	else:
		debug_options_window.hide()


func _on_dig_button_toggled(toggled_on: bool) -> void:
	selection_manager.tile_selection_enable = toggled_on
	
