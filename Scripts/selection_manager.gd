extends Control

@onready var ground = get_node("../../Map Generator/NavigationRegion2D/TileMapLayer")
@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
@export var rect_width := int(3)
@export var rect_color := Color(0.639, 0.0, 0.0, 1.0)
var selection_rect_local = Rect2()
var drawing = false
var start_pos : Vector2
var end_pos : Vector2
#func _ready() -> void:
	#UnitManager.selection_manager = self
	
#
func _draw():
	if drawing:
		selection_rect_local = Rect2(start_pos, end_pos - start_pos).abs()
		draw_rect(selection_rect_local, rect_color, false, rect_width)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = get_global_mouse_position()
			drawing = true
		elif event.is_released():
			drawing = false
			queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		UnitManager.move_to_position(ground, get_tile_pos(get_global_mouse_position()))
	if event is InputEventMouseMotion and drawing:
		end_pos = get_global_mouse_position()
		get_selection(selection_rect_local)
		queue_redraw()
		
		

		
#func _convert_selection_rect(screen_rect: Rect2):
	#var canvas_transform_inverse = camera.get_canvas_transform().affine_inverse()
	#var world_pos_top_left = canvas_transform_inverse * screen_rect.position
	#var world_pos_bottom_right = canvas_transform_inverse * (screen_rect.position + screen_rect.size)
	#var global_rect = Rect2(world_pos_top_left, world_pos_bottom_right - world_pos_top_left)
	#return global_rect


func get_tile_pos(global_pos):
	var local_pos = ground.to_local(global_pos)
	var tile_pos = ground.local_to_map(local_pos)
	
	return tile_pos

func get_selection(converted_rect):
	for unit in get_tree().get_nodes_in_group("Units"):
		
		if converted_rect.has_point(unit.global_position):
			unit.select()
			unit.add_to_group("Selected Units")
		else:
			unit.deselect()
			unit.remove_from_group("Selected Units")
	
	return converted_rect

	
