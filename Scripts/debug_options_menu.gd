extends PanelContainer


@onready var main = $"../../../Main"
@onready var selection_manager := get_tree().get_first_node_in_group("Selection Manager")
@onready var camera := $"../../../Main/CameraController"
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

### Camera Options Variables ###

@onready var enable_edge_scroll_cb: CheckBox = $"VBoxContainer/TabContainer/Camera/Enable Edge Scroll CB"
@onready var edge_scroll_speed_sb: SpinBox = $"VBoxContainer/TabContainer/Camera/Edge Scroll Speed SB"
@onready var edge_scroll_dist_sb: SpinBox = $"VBoxContainer/TabContainer/Camera/Edge Scroll Dist SB"
@onready var max_zoom_in_sb: SpinBox = $"VBoxContainer/TabContainer/Camera/Max Zoom In SB"
@onready var max_zoom_out_sb: SpinBox = $"VBoxContainer/TabContainer/Camera/Max Zoom Out SB"
@onready var zoom_speed_sb: SpinBox = $"VBoxContainer/TabContainer/Camera/Zoom Speed SB"


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
	
	### Camera Options - align with preset defaults
	enable_edge_scroll_cb.button_pressed = camera.enable_edge_scroll
	edge_scroll_speed_sb.value = camera.scroll_speed
	edge_scroll_dist_sb.value = camera.edge_dist
	max_zoom_in_sb.value = camera.max_zoom_in
	max_zoom_out_sb.value = camera.max_zoom_out
	zoom_speed_sb.value = camera.zoom_speed
	
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
	selection_manager.path_visual_enable = toggled_on
	for u in get_tree().get_nodes_in_group("Units"):
		u.queue_redraw()




func _on_path_line_color_cpb_color_changed(color: Color) -> void:
	selection_manager.path_visual_line_color = color
	
		


func _on_path_line_width_sb_value_changed(value: float) -> void:
	selection_manager.path_visual_line_width = value
	
	


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


### Camera Options ###

func _on_enable_edge_scroll_cb_toggled(toggled_on: bool) -> void:
	camera.enable_edge_scroll = toggled_on


func _on_edge_scroll_speed_sb_value_changed(value: float) -> void:
	camera.scroll_speed = value


func _on_edge_scroll_dist_sb_value_changed(value: float) -> void:
	camera.edge_dist = value


func _on_max_zoom_in_sb_value_changed(value: float) -> void:
	camera.max_zoom_in = value


func _on_max_zoom_out_sb_value_changed(value: float) -> void:
	camera.max_zoom_out = value


func _on_zoom_speed_sb_value_changed(value: float) -> void:
	camera.zoom_speed = value
