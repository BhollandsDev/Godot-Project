extends Node2D

@onready var water_tileset: TileMapLayer = $water
@onready var ground_tileset: TileMapLayer = $ground
@onready var ground_2_tileset: TileMapLayer = $ground2
@export var noise := FastNoiseLite.new()
@onready var selection_manager = get_node("../Selection Draw")


var source_id := 0
var terrain_set := 0
var water_tiles :=[
	Vector2i(13,13),
	Vector2i(14,13),
	Vector2i(15,13),
	Vector2i(16,13)
]

#const TILE_SIZE_SETTER := 32
const CHUNK_SIZE := 32
const ACTIVE_RADIUS := 1 # chunks activley around camera (3x3)
const PRELOAD_RADIUS := 5 # background preloading (5x5 total)
const CHUNKS_PER_FRAME_LIMIT := 1

var _last_radius := 1
var generated_chunks := {}
var _chunk_draw_queue: Array = []
var generation_queue: Array[Vector2i] = []
var preload_queue: Array[Vector2i] = []

var last_chunk_coords := Vector2i(99999, 99999)

#var _chunk_finished_count := 0


func _ready() -> void:
	randomize()
	noise.seed = randi()

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	var camera_pos = camera.position
	var tile_size = water_tileset.tile_set.tile_size
	
	
	var current_chunk_coords = Vector2i(
		floor(camera_pos.x / (CHUNK_SIZE * tile_size.x)),
		floor(camera_pos.y / (CHUNK_SIZE * tile_size.y))
	)
	
	var current_zoom = camera.zoom.x
	var calculated_radius = int(ceil(ACTIVE_RADIUS / current_zoom))
	var dynamic_radius = clamp(calculated_radius, 1, 8)
	
	
	if current_chunk_coords != last_chunk_coords or dynamic_radius != _last_radius:
		last_chunk_coords = current_chunk_coords
		_last_radius = dynamic_radius
		_update_chunk_queues(current_chunk_coords, dynamic_radius)
	
	_process_generation_queues()
	_process_draw_queue()
	

func _update_chunk_queues(center_chunk: Vector2i, radius: int) -> void:
	for x in range(center_chunk.x - radius, center_chunk.x + radius + 1):
		for y in range(center_chunk.y - radius, center_chunk.y + radius + 1):
			var c = Vector2i(x, y)
			if not generated_chunks.has(c):
				generated_chunks[c] = true
				generation_queue.append(c)
	
	var preload_r = radius + PRELOAD_RADIUS
	
	for x in range(center_chunk.x - preload_r, center_chunk.x + preload_r + 1):
		for y in range(center_chunk.y - preload_r, center_chunk.y + preload_r + 1):
			var c = Vector2i(x, y)
			if not generated_chunks.has(c) and not generation_queue.has(c):
				generated_chunks[c] = true
				preload_queue.append(c)

func _process_generation_queues() -> void:
	if generation_queue.size() > 0:
		var next_chunk = generation_queue.pop_front()
		WorkerThreadPool.add_task(_thread_calculate_chunk_data.bind(next_chunk))
		
		
	elif preload_queue.size() > 0:
		var next_preload = preload_queue.pop_front()
		WorkerThreadPool.add_task(_thread_calculate_chunk_data.bind(next_preload))
	

func _thread_calculate_chunk_data(chunk_coords: Vector2i) -> void:
	var start_x = chunk_coords.x * CHUNK_SIZE
	var start_y = chunk_coords.y * CHUNK_SIZE
	
	var water_cells_data = []
	var ground_cells_array: Array[Vector2i] = []
	var walkable_cells_array: Array[Vector2i] = []
	
	var cell_count := CHUNK_SIZE * CHUNK_SIZE
	
	for i in range(cell_count):
		var x = i % CHUNK_SIZE
		var y = i / CHUNK_SIZE
		var world_x = start_x + x
		var world_y = start_y + y
		var cell := Vector2i(world_x, world_y)
		
		var noise_val: float = noise.get_noise_2d(world_x, world_y)
		
		water_cells_data.append({
			"cell": cell,
			"atlas_coords": water_tiles.pick_random()
		})
		
		if noise_val >= 0.0:
			ground_cells_array.append(cell)
			walkable_cells_array.append(cell)

	call_deferred("_apply_chunk_data_to_map", water_cells_data, ground_cells_array, walkable_cells_array)

func _apply_chunk_data_to_map(water_data: Array, ground_cells: Array[Vector2i], walkable_cells: Array[Vector2i]):
	_chunk_draw_queue.append({
		"water": water_data,
		"ground": ground_cells,
		"walkable": walkable_cells
	})

func _process_draw_queue() -> void:
	if _chunk_draw_queue.is_empty():
		return
	
	for i in range(CHUNKS_PER_FRAME_LIMIT):
		if _chunk_draw_queue.is_empty():
			break
		var data = _chunk_draw_queue.pop_front()
		_draw_single_chunk(data)

func _draw_single_chunk(data: Dictionary) -> void:
	for d in data["water"]:
		water_tileset.set_cell(d["cell"], source_id, d["atlas_coords"])
	
	if data["ground"].size() > 0:
		ground_tileset.set_cells_terrain_connect(data["ground"], terrain_set, 1, false)
	
	if data["walkable"].size() > 0:
		PathfindingManager.add_walkable_cells(data["walkable"])
		

func _on_unit_dig_complete(target_pos: Vector2):
	var cell = ground_tileset.local_to_map(target_pos)
	ground_tileset.set_cell(Vector2i(cell.x, cell.y), -1)
	
func is_tile_reachable(tile: Vector2i) -> bool:
	return ground_tileset.get_cell_source_id(tile) != -1
