extends PanelContainer

@onready var debug_options: PanelContainer = $"."
@onready var camera_controller = get_tree().get_first_node_in_group("camera_controller")
@onready var selection_manager = get_tree().get_first_node_in_group("Selection Manager")
@onready var path_visualizer = get_tree().get_first_node_in_group("Path Visualizer")
@onready var camera = get_tree().get_first_node_in_group("MainCamera").get_parent()

### Grid Line Variables ###

#@onready var grid_line_width: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Grid Line Width"
#@onready var gridline_color_cpb: ColorPickerButton = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Gridline Color CPB"
@onready var grid_line_enable_toggle: CheckBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Grid Line Enable"



### Selection Box Variables ###

@onready var selectionbox_min_size: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Min Size"
@onready var selectionbox_line_width: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Line Width"
@onready var selectionbox_color_cpb: ColorPickerButton = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Color CPB"

### Path Visualization variable ###

@onready var path_visual_enable: CheckBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer3/Path Visual Enable"
@onready var path_line_width: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer3/Path Line Width"
@onready var path_line_color_cpb: ColorPickerButton = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer3/Path Line Color CPB"

#### Misc ####

@onready var camera_zoom_sb: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer3/Camera Zoom SB"


#func _ready() -> void:
	#grid_line_width.value = selection_manager.grid_line_width
	#gridline_color_cpb.color = selection_manager.grid_line_color
	#grid_line_enable_toggle.button_pressed = selection_manager.grid_line_enable
	#
	#selectionbox_min_size.value = selection_manager.selection_min_rect_size
	#selectionbox_line_width.value = selection_manager.selection_rect_width
	#selectionbox_color_cpb.color = selection_manager.selection_rect_color
	#
	##path_visual_enable.button_pressed = path_visualizer.show_paths
	#path_line_width.value = path_visualizer.path_width
	#path_line_color_cpb.color = path_visualizer.path_color
	#
	#camera_zoom_sb.value = camera.max_zoom_out
	
func _on_close_windows_button_pressed() -> void:
	debug_options.hide()



func _on_edge_scroll_enable_toggled(toggled_on: bool) -> void:
	
	camera_controller.edge_scroll = toggled_on
	print(toggled_on)


###### Grid Line Options ##############

#func _on_grid_line_enable_toggled(toggled_on: bool) -> void:
	#selection_manager.grid_line_enable = toggled_on


#func _on_gridline_color_cpb_color_changed(color: Color) -> void:
	#selection_manager.grid_line_color = color
	
	
#func _on_grid_line_width_value_changed(value: float) -> void:
	#selection_manager.grid_line_width = value

###### Selection Box Options #########

#func _on_selectionbox_min_size_value_changed(value: float) -> void:
	#selection_manager.selection_min_rect_size = value


#func _on_selectionbox_line_width_value_changed(value: float) -> void:
	#selection_manager.selection_rect_width = value


#func _on_selectionbox_color_cpb_color_changed(color: Color) -> void:
	#selection_manager.selection_rect_color = color
	
##### Path Visualizer ########

func _on_path_visual_enable_toggled(toggled_on: bool) -> void:
	path_visualizer.show_paths = toggled_on
	

func _on_path_line_width_value_changed(value: float) -> void:
	path_visualizer.path_width = value


func _on_path_line_color_cpb_color_changed(color: Color) -> void:
	path_visualizer.path_color = color
	
	###### Camera Settings #######
	

func _on_camera_zoom_sb_value_changed(value: int) -> void:
	camera.max_zoom_out = value
