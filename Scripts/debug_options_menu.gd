extends PanelContainer


@onready var main = $"../../../Main"
@onready var selection_manager := get_tree().get_first_node_in_group("Selection Manager")
var drag_point = null
var agents := []




### Grid Option Variables ###
@onready var grid_enable_cb: CheckBox = $"VBoxContainer/TabContainer/Grid/Grid Enable CB"
@onready var line_width_sb: SpinBox = $"VBoxContainer/TabContainer/Grid/Line Width SB"
@onready var line_color_cpb: ColorPickerButton = $"VBoxContainer/TabContainer/Grid/Line Color CPB"

### Unit Path Visualization Variables ###
@onready var enable_path_visual_cb: CheckBox = $"VBoxContainer/TabContainer/Path Visual/Enable Path Visual CB"
@onready var path_line_width_sb: SpinBox = $"VBoxContainer/TabContainer/Path Visual/Path Line Width SB"
@onready var path_line_color_cpb: ColorPickerButton = $"VBoxContainer/TabContainer/Path Visual/Path Line Color CPB"

### Selection Box Button Variables ###
@onready var selec_box_min_size_sb: SpinBox = $"VBoxContainer/TabContainer/Selection Box/SelecBox Min Size SB"
@onready var selec_box_line_width_sb: SpinBox = $"VBoxContainer/TabContainer/Selection Box/SelecBox Line Width SB"
@onready var selec_box_line_color_cpb: ColorPickerButton = $"VBoxContainer/TabContainer/Selection Box/SelecBox Line Color CPB"
@onready var selec_box_filled_cb: CheckBox = $"VBoxContainer/TabContainer/Selection Box/SelecBox Filled CB"


func _ready() -> void:
	
	## Grid -align with preset defaults ##
	grid_enable_cb.button_pressed = selection_manager.grid_line_enable
	line_width_sb.value = selection_manager.grid_line_width
	line_color_cpb.color = selection_manager.grid_line_color

	## Path - align with preset defaults ##
	enable_path_visual_cb.button_pressed = selection_manager.path_visual_enable
	path_line_width_sb.value = selection_manager.path_visual_line_width
	path_line_color_cpb.color = selection_manager.path_visual_line_color
	
	### SelectionBox - align with preset defaults
	selec_box_min_size_sb.value = selection_manager.selection_min_rect_size
	selec_box_line_width_sb.value = selection_manager.selection_rect_width
	selec_box_line_color_cpb.color = selection_manager.selection_rect_color
	selec_box_filled_cb.button_pressed = selection_manager.selection_rect_filled

#### Input Connections ####

func _on_title_bar_pc_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				
				drag_point = get_global_mouse_position() - get_screen_position()
			elif event.is_released():
				drag_point = null
				
	if event is InputEventMouseMotion and drag_point != null:
		set_position(get_global_mouse_position() - drag_point)


func _on_enable_path_visual_cb_toggled(toggled_on: bool) -> void:
	main.path_visualization_enable = toggled_on
	for unit in get_tree().get_nodes_in_group("Units"):
		unit.nav_agent.debug_enabled = toggled_on




func _on_path_line_color_cpb_color_changed(color: Color) -> void:
	main.path_visualization_enable = true
	main.path_visualization_color = color
	for unit in get_tree().get_nodes_in_group("Units"):
		unit.nav_agent.debug_use_custom = true
		unit.nav_agent.debug_path_custom_color = color
		


func _on_path_line_width_sb_value_changed(value: float) -> void:
	main.path_line_width = value
	for unit in get_tree().get_nodes_in_group("Units"):
		unit.nav_agent.debug_path_custom_line_width = value
	


func _on_line_width_sb_value_changed(value: float) -> void:
	selection_manager.grid_line_width = value
	selection_manager.queue_redraw()

func _on_line_color_cpb_color_changed(color: Color) -> void:
	selection_manager.grid_line_color = color
	selection_manager.queue_redraw()


func _on_grid_enable_cb_toggled(toggled_on: bool) -> void:
	selection_manager.grid_line_enable = toggled_on
	selection_manager.queue_redraw()
	print(selection_manager.grid_line_enable)

func _on_close_button_pressed() -> void:
	self.hide()


func _on_selec_box_min_size_sb_value_changed(value: float) -> void:
	selection_manager.selection_min_rect_size = value


func _on_selec_box_line_width_sb_value_changed(value: float) -> void:
	selection_manager.selection_rect_width = value


func _on_selec_box_line_color_cpb_color_changed(color: Color) -> void:
	selection_manager.selection_rect_color = color


func _on_selec_box_filled_cb_toggled(toggled_on: bool) -> void:
	selection_manager.selection_rect_filled = toggled_on
