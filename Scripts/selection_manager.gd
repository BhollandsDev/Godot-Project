extends Node2D
@onready var main: Node2D = $".."


@onready var map_generator = get_node("../Map Generator")
@onready var water = get_node("../Map Generator/water")
@onready var ground = get_node("../Map Generator/ground")
@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
@onready var camera := get_tree().get_nodes_in_group("MainCamera")
@onready var user_interface := $"../User Interface/UI"
@onready var tile_size : int = map_generator.TILE_SIZE_SETTER

@export var selection_min_rect_size := 10
@export var selection_rect_width := 3
@export var selection_rect_color : Color = Color.GREEN
@export var selection_rect_filled := false

@export var grid_line_enable: bool = false
@export var grid_line_width = 2

@export var grid_line_color:= Color(0.0, 0.0, 0.0, 1.0)

@export var path_visual_enable : bool = false
@export var path_visual_line_width: int = 2
@export var path_visual_line_color: Color = Color.RED

var test := true

var selection_rect_local = Rect2()
var selection_drawing : bool = false

var tile_selection_enable := false
var tile_selection_enable_start := false

var draw_dig_tile_selection: Array = []

var start_pos : Vector2
var end_pos : Vector2


func _ready() -> void:
	process_priority = 1

	
	
func _draw():
	#debug_path_visual()
	draw_grid_lines()
	selection_draw()
	
	for tiles in draw_dig_tile_selection:
		var tile_pos = tiles * tile_size
		draw_rect(Rect2(tile_pos,Vector2(32, 32)),Color.RED, false, 2.0)
		
	for tiles in JobManager.claimed_dig_jobs:
		var tile_pos = tiles * tile_size
		draw_rect(Rect2(tile_pos,Vector2(32, 32)),Color.GREEN, false, 2.0)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if user_interface.mine_button.button_pressed:
				tile_selection_enable_start = true
			else:
				selection_drawing = true
			start_pos = get_global_mouse_position()
			queue_redraw()
			
		elif event.is_released():
			if user_interface.mine_button.button_pressed:
				user_interface.mine_button.button_pressed = false
			selection_drawing = false
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO
			tile_selection_enable = false
			tile_selection_enable_start = false
			_update_draw_dig_tiles()
			JobManager.available_dig_jobs = draw_dig_tile_selection
			JobManager._match_jobs_to_units()
			queue_redraw()
			
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			#main.move_to_position()
			main.move_to_position(ground, get_tile_pos(get_global_mouse_position()))
			
	if event is InputEventMouseMotion and selection_drawing || tile_selection_enable_start:
		end_pos = get_global_mouse_position()
		get_unit_selection(selection_rect_local)
		_update_draw_dig_tiles()

		queue_redraw()
	

func _update_draw_dig_tiles():
	if tile_selection_enable_start:
		var start_local = ground.to_local(start_pos)
		var end_local = ground.to_local(end_pos)
		var start_tile = ground.local_to_map(start_local)
		var end_tile = ground.local_to_map(end_local)
		var tiles : Array[Vector2i] = []
		var x1 = min(start_tile.x, end_tile.x)
		var x2 = max(start_tile.x, end_tile.x)
		var y1 = min(start_tile.y, end_tile.y)
		var y2 = max(start_tile.y, end_tile.y)

		for x in range(x1,x2 + 1):
			for y in range(y1,y2 + 1):
					tiles.append(Vector2i(x, y))
					
		if Input.is_action_pressed("ui_shift"):
			for t in tiles:
				if not draw_dig_tile_selection.has(t):
					draw_dig_tile_selection.append(t) 
		else:
			draw_dig_tile_selection = tiles
		
		draw_dig_tile_selection = draw_dig_tile_selection.filter(func(tile):
			return map_generator.is_tile_reachable(tile))

		queue_redraw()
		
func selection_draw() -> void:	
	if selection_drawing and start_pos != Vector2.ZERO and end_pos != Vector2.ZERO:
		if selection_drawing and start_pos.distance_to(end_pos) > selection_min_rect_size:
			selection_rect_local = Rect2(start_pos, end_pos - start_pos).abs()
			draw_rect(selection_rect_local, selection_rect_color, selection_rect_filled, selection_rect_width)

func get_tile_pos(global_pos):
	var local_pos = ground.to_local(global_pos)
	var tile_pos = ground.local_to_map(local_pos)
	return tile_pos


func get_unit_selection(converted_rect):
	if selection_drawing:
		for unit in get_tree().get_nodes_in_group("Units"):
			if converted_rect.has_point(unit.global_position):
				unit.select()
				unit.add_to_group("Selected Units")
				
			else:
				unit.deselect()
				unit.remove_from_group("Selected Units")
				
		return converted_rect

func draw_grid_lines():
	var size = get_viewport_rect().size
	var cam = get_viewport().get_camera_2d().position
	### Tile Outlines ###
	if grid_line_enable:
		for i in range(int((cam.x - size.x) / 32) - 1, int((size.x + cam.x) / 32) + 1):
			draw_line(Vector2(i * 32, cam.y + size.y + 100), Vector2(i * 32, cam.y - size.y - 100), grid_line_color, grid_line_width)
		for i in range(int((cam.y - size.y) / 32) - 1, int((size.y + cam.y) / 32) + 1):
			draw_line(Vector2(cam.x + size.x + 100, i * 32), Vector2(cam.x - size.x - 100, i * 32), grid_line_color, grid_line_width)
	
	### Chunk Outlines ###
	if grid_line_enable:
		for i in range(int((cam.x - size.x) / (32 * 32)) - 1, int((size.x + cam.x) / (32 * 32)) + 1):
			draw_line(Vector2(i * (32 * 32), cam.y + size.y + 100), Vector2(i * (32 * 32), cam.y - size.y - 100), grid_line_color, (grid_line_width * 2))
		for i in range(int((cam.y - size.y) / (32 * 32)) - 1, int((size.y + cam.y) / (32 * 32)) + 1):
			draw_line(Vector2(cam.x + size.x + 100, i * (32 * 32)), Vector2(cam.x - size.x - 100, i * (32 * 32)), grid_line_color, (grid_line_width * 2))

#func debug_path_visual():
	#if path_visual_enable:
		#var units = get_tree().get_nodes_in_group("Units")
		#for u in units:
			#if u.current_path_index >= u.current_path.size():
				#return
			#var points = PackedVector2Array()
			#points.append(Vector2.ZERO)
			#
			#for i in range(u.current_path_index, u.current_path.size()):
				#points.append(u.to_local(u.current_path[i]))
			#
			#if points.size() >= 2:
				#draw_polyline(points, path_visual_line_color, path_visual_line_width)
