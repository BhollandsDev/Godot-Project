extends Node2D
@onready var main: Node2D = $".."
@onready var map_generator = get_node("../Map Generator")
#@onready var water = get_node("../Map Generator/water")
@onready var ground = get_node("../Map Generator/ground")
@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
@onready var user_interface := $"../User Interface/UI"


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

#var test := true
var selection_rect_local = Rect2()
var selection_drawing : bool = false
#var tile_selection_enable := false
#var tile_selection_enable_start := false
#var draw_dig_tile_selection: Array = []
#var start_pos : Vector2
#var end_pos : Vector2
var is_selecting_dig_area_setter: bool = false
var is_selecting_dig_area: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var drag_end_pos: Vector2 = Vector2.ZERO
var preview_tiles: Array[Vector2i] = []

@export var selection_color_preview: Color = Color(1.0, 1.0, 1.0, 0.3)
@export var selection_color_pending: Color = Color(1.0, 0.0, 0.0, 0.4)
@export var selection_color_claimed: Color = Color(1.0, 1.0, 0.0, 0.4)

func _ready() -> void:
	process_priority = 1


func _draw() -> void:
	draw_grid_lines()
	_draw_job_highlights()
	_draw_selection_preview()
	selection_draw()
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_selecting_dig_area:
				is_selecting_dig_area_setter = true
				drag_start_pos = get_global_mouse_position()
			if not is_selecting_dig_area:
				selection_drawing = true
				drag_start_pos = get_global_mouse_position()
		elif event.is_released():
			is_selecting_dig_area_setter = false
			_submit_dig_jobs()
			selection_drawing = false
			#is_selecting_dig_area = false
			preview_tiles.clear()
			drag_start_pos = Vector2.ZERO
			drag_end_pos = Vector2.ZERO
			user_interface.mine_button.button_pressed = false
			
			queue_redraw()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			main.move_to_position(ground, ground.local_to_map(get_global_mouse_position()))
	
	if event is InputEventMouseMotion:
		if selection_drawing:
			drag_end_pos = get_global_mouse_position()
			get_unit_selection(selection_rect_local)
		if is_selecting_dig_area_setter:
			drag_end_pos = get_global_mouse_position()
			_update_preview_tiles()
		queue_redraw()
		
		
func _draw_job_highlights():
	for tile in JobManager.available_dig_jobs.keys():
		var local_pos = ground.map_to_local(tile)
		var tile_rect = Rect2(local_pos - Vector2(16, 16), Vector2(32, 32))
		
		draw_rect(tile_rect, selection_color_pending, true)
		draw_rect(tile_rect, Color.RED, false, 1.0)
		
	for tile in JobManager.claimed_dig_jobs.keys():
		var local_pos = ground.map_to_local(tile)
		var tile_rect = Rect2(local_pos - Vector2(16, 16), Vector2(32, 32))
		
		draw_rect(tile_rect, selection_color_claimed, true)
		draw_rect(tile_rect, Color.YELLOW, false, 1.0)
		
func _update_preview_tiles():
	preview_tiles.clear()
	
	var start_local = ground.to_local(drag_start_pos)
	var end_local = ground.to_local(drag_end_pos)
	var start_tile = ground.local_to_map(start_local)
	var end_tile = ground.local_to_map(end_local)
	var x_min = min(start_tile.x, end_tile.x)
	var x_max = max(start_tile.x, end_tile.x)
	var y_min = min(start_tile.y, end_tile.y)
	var y_max = max(start_tile.y, end_tile.y)
	
	for x in range(x_min, x_max + 1):
		for y in range(y_min, y_max + 1):
			var tile = Vector2i(x, y)
			if map_generator.is_tile_reachable(tile):
				preview_tiles.append(tile)

func _draw_selection_preview():
	if not is_selecting_dig_area:
		return
	
	var rect = Rect2(drag_start_pos, drag_end_pos - drag_start_pos)
	draw_rect(rect, Color.WHITE, false, 2.0)
	
	for tile in preview_tiles:
		var local_pos = ground.map_to_local(tile)
		var tile_rect = Rect2(local_pos - Vector2(16, 16), Vector2(32, 32))
		draw_rect(tile_rect, selection_color_preview, true)

func _submit_dig_jobs():
	for tile in preview_tiles:
		JobManager.add_dig_job(tile)

#func _update_draw_dig_tiles():
	#if tile_selection_enable_start:
		#var start_local = ground.to_local(start_pos)
		#var end_local = ground.to_local(end_pos)
		#var start_tile = ground.local_to_map(start_local)
		#var end_tile = ground.local_to_map(end_local)
		#var tiles : Array[Vector2i] = []
		#var x1 = min(start_tile.x, end_tile.x)
		#var x2 = max(start_tile.x, end_tile.x)
		#var y1 = min(start_tile.y, end_tile.y)
		#var y2 = max(start_tile.y, end_tile.y)
#
		#for x in range(x1,x2 + 1):
			#for y in range(y1,y2 + 1):
					#tiles.append(Vector2i(x, y))
					#
		#if Input.is_action_pressed("ui_shift"):
			#for t in tiles:
				#if not draw_dig_tile_selection.has(t):
					#draw_dig_tile_selection.append(t) 
		#else:
			#draw_dig_tile_selection = tiles
		#
		#draw_dig_tile_selection = draw_dig_tile_selection.filter(func(tile):
			#return map_generator.is_tile_reachable(tile))
#
		#queue_redraw()
		

func selection_draw() -> void:	
	if is_selecting_dig_area:
		return
	if selection_drawing and drag_start_pos != Vector2.ZERO and drag_end_pos != Vector2.ZERO:
		if selection_drawing and drag_start_pos.distance_to(drag_end_pos) > selection_min_rect_size:
			selection_rect_local = Rect2(drag_start_pos, drag_end_pos - drag_start_pos).abs()
			draw_rect(selection_rect_local, selection_rect_color, selection_rect_filled, selection_rect_width)

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
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var viewport_size = get_viewport_rect().size
	var zoom = camera.zoom
	var cam = camera.position
	var visible_size = viewport_size / zoom
	var half_size = (visible_size / 2) + Vector2(2000, 2000)
	var start_x = int((cam.x - half_size.x) / 32)
	var end_x = int((cam.x + half_size.x) / 32)
	var start_y = int((cam.y - half_size.y) / 32)
	var end_y = int((cam.y + half_size.y) / 32)
	
	if grid_line_enable:
		for i in range(start_x, end_x + 1):
			var x_pos = i * 32
			draw_line(Vector2(x_pos, cam.y - half_size.y), Vector2(x_pos, cam.y + half_size.y), grid_line_color, grid_line_width )
		
		for i in range(start_y, end_y + 1):
			var y_pos = i * 32
			draw_line(Vector2(cam.x - half_size.x, y_pos), Vector2(cam.x + half_size.x, y_pos), grid_line_color, grid_line_width)
	
	if grid_line_enable:
		var chunk_size = 32 * 32
		var chunk_start_x = int((cam.x - half_size.x) / chunk_size)
		var chunk_end_x = int((cam.x + half_size.x) / chunk_size)
		var chunk_start_y = int((cam.y - half_size.y) / chunk_size)
		var chunk_end_y = int((cam.y + half_size.y) / chunk_size)
		
		for i in range(chunk_start_x, chunk_end_x + 1):
			var x_pos = i * chunk_size
			draw_line(Vector2(x_pos, cam.y - half_size.y), Vector2(x_pos, cam.y + half_size.y), grid_line_color, grid_line_width * 5)
			
		for i in range(chunk_start_y, chunk_end_y + 1):
			var y_pos = i * chunk_size
			draw_line(Vector2(cam.x - half_size.x, y_pos), Vector2(cam.x + half_size.x, y_pos), grid_line_color, grid_line_width * 5)
	
