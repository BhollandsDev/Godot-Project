extends Node2D

@onready var main = $"../../../Main"
@onready var water = get_node("../../Map Generator/water")
@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
@onready var camera := get_tree().get_nodes_in_group("MainCamera")

@export var selection_min_rect_size := 10
@export var selection_rect_width := 3
@export var selection_rect_color := Color(0.463, 0.0, 0.0, 0.552)
@export var selection_rect_filled := false

@export var grid_line_enable: bool = false
@export var grid_line_width = 2
@export var grid_line_color:= Color(0.0, 0.0, 0.0, 1.0)

@export var path_visual_enable : bool = false
@export var path_visual_line_width: int = 2
@export var path_visual_line_color: Color = Color.RED

var selection_rect_local = Rect2()
var drawing = false
var start_pos : Vector2
var end_pos : Vector2
#var testing := false
func _ready() -> void:
	process_priority = 1
	
#func _process(_delta):
	#if drawing:
		#queue_redraw()
	#if testing:
		#queue_redraw()
	
	

func _draw():
	
	draw_grid_lines()
	if drawing and start_pos != Vector2.ZERO and end_pos != Vector2.ZERO:
		if drawing and start_pos.distance_to(end_pos) > selection_min_rect_size:
			selection_rect_local = Rect2(start_pos, end_pos - start_pos).abs()
			draw_rect(selection_rect_local, selection_rect_color, selection_rect_filled, selection_rect_width)
	
	
		
	



	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = get_global_mouse_position()
			drawing = true
			#queue_redraw()
		elif event.is_released():
			drawing = false
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO
			queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			main.move_to_position(water, get_tile_pos(get_global_mouse_position()))
	if event is InputEventMouseMotion and drawing:
		end_pos = get_global_mouse_position()
		get_selection(selection_rect_local)
		queue_redraw()
		


func get_tile_pos(global_pos):
	var local_pos = water.to_local(global_pos)
	var tile_pos = water.local_to_map(local_pos)
	
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

func draw_grid_lines():
	var size = get_viewport_rect().size # * get_viewport().get_camera_2d().zoom / 2
	var cam = get_viewport().get_camera_2d().position
	
	if grid_line_enable:
		
		for i in range(int((cam.x - size.x) / 32) - 1, int((size.x + cam.x) / 32) + 1):
			draw_line(Vector2(i * 32, cam.y + size.y + 100), Vector2(i * 32, cam.y - size.y - 100), grid_line_color, grid_line_width)
		for i in range(int((cam.y - size.y) / 32) - 1, int((size.y + cam.y) / 32) + 1):
			draw_line(Vector2(cam.x + size.x + 100, i * 32), Vector2(cam.x - size.x - 100, i * 32), grid_line_color, grid_line_width)
	
