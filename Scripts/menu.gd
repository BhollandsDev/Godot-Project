extends Control
@onready var add_btn = $Add
@onready var del_btn = $Delete
@export var target_scene: PackedScene

var unit_scene
var current_inst
var parent_node

func _ready():
	add_btn.pressed.connect(_add_button_pressed)
	del_btn.pressed.connect(_del_button_pressed)
	
	

	
func _add_button_pressed():
	UnitManager.add_unit()
	
func _del_button_pressed():
	UnitManager.delete_selected_units()
	print("Deleted")


func _on_edge_scrolling_toggle_toggled(toggled_on: bool) -> void:
	var camera_controller = get_tree().get_first_node_in_group("camera_controller")
	camera_controller.edge_scroll = toggled_on
	if toggled_on == true:
		print("Enabled")
	else:
		print("Disabled")
