extends PanelContainer

@onready var debug_options: PanelContainer = $"."
@onready var camera_controller = get_tree().get_first_node_in_group("camera_controller")
@onready var selection_manager = get_tree().get_first_node_in_group("SelectionManager")

### Grid Line Variables ###

@onready var grid_line_width: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Grid Line Width"
@onready var gridline_color_cpb: ColorPickerButton = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Gridline Color CPB"
@onready var grid_line_enable_toggle: CheckBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer/Grid Line Enable"

### Selection Box Variables ###

@onready var selectionbox_min_size: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Min Size"
@onready var selectionbox_line_width: SpinBox = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Line Width"
@onready var selectionbox_color_cpb: ColorPickerButton = $"MarginContainer/VBoxContainer/GridContainer2/VBoxContainer2/Selectionbox Color CPB"


func _ready() -> void:
	grid_line_width.value = selection_manager.grid_line_width
	gridline_color_cpb.color = selection_manager.grid_line_color
	grid_line_enable_toggle.button_pressed = selection_manager.grid_line_enable
	
	selectionbox_min_size.value = selection_manager.selection_min_rect_size
	selectionbox_line_width.value = selection_manager.selection_rect_width
	selectionbox_color_cpb.color = selection_manager.selection_rect_color
	
func _on_close_windows_button_pressed() -> void:
	debug_options.hide()



func _on_edge_scroll_enable_toggled(toggled_on: bool) -> void:
	
	camera_controller.edge_scroll = toggled_on
	print(toggled_on)


###### Grid Line Options ##############

func _on_grid_line_enable_toggled(toggled_on: bool) -> void:
	selection_manager.grid_line_enable = toggled_on


func _on_gridline_color_cpb_color_changed(color: Color) -> void:
	selection_manager.grid_line_color = color
	
	
func _on_grid_line_width_value_changed(value: float) -> void:
	selection_manager.grid_line_width = value

###### Selection Box Options #########

func _on_selectionbox_min_size_value_changed(value: float) -> void:
	selection_manager.selection_min_rect_size = value


func _on_selectionbox_line_width_value_changed(value: float) -> void:
	selection_manager.selection_rect_width = value


func _on_selectionbox_color_cpb_color_changed(color: Color) -> void:
	selection_manager.selection_rect_color = color
