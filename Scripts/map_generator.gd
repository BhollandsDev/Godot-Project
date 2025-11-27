extends Node2D

@onready var water_tileset: TileMapLayer = $water
@onready var ground_tileset: TileMapLayer = $ground
@onready var ground_2_tileset: TileMapLayer = $ground2
@export var noise := FastNoiseLite.new()
@onready var selection_manager = get_node("../Selection Draw")

var source_id := 0
var terrain_set := 0
var water_tiles_array : Array
var water_terrain_int := 0
var ground_tiles_array : Array
var ground_terrain_int := 1
var noise_val_array : Array
var water_tiles :=[
	Vector2i(13,13),
	Vector2i(14,13),
	Vector2i(15,13),
	Vector2i(16,13)
]
const TILE_SIZE_SETTER := 32
const CHUNK_SIZE := 32
const CELLS_PER_FRAME := 128 #how many tiles procesed before yielding
const ACTIVE_RADIUS := 1 # chunks activley around camera (3x3)
const PRELOAD_RADIUS := 5 # background preloading (5x5 total)
#const UNLOAD_DISTANCE := 3


var generated_chunks := {}
#var loading_chunks := {} #currently loading threads
var chunk_results_queue: Array = []

#var chunks_in_progress := {}
var generation_queue := []
var preload_queue := []
#var finished_threads: Array = []

var selection_rect : Rect2
var selection_width : int

var selected_cell := Vector2i(-1, -1)




func _ready() -> void:
	randomize()
	noise.seed = randi()
	

func _process(_delta: float) -> void:
	var camera_pos = get_viewport().get_camera_2d().position
	var tile_size = water_tileset.tile_set.tile_size
	var chunk_coords = Vector2i(
		floor(camera_pos.x / (CHUNK_SIZE * tile_size.x)),
		floor(camera_pos.y / (CHUNK_SIZE * tile_size.y))
	)

	# Generate active chunks first (close to camera)
	for x in range(chunk_coords.x - ACTIVE_RADIUS, chunk_coords.x + ACTIVE_RADIUS + 1):
		for y in range(chunk_coords.y - ACTIVE_RADIUS, chunk_coords.y + ACTIVE_RADIUS + 1):
			var c = Vector2i(x, y)
			if not generated_chunks.has(c):
				generated_chunks[c] = true
				generation_queue.append(c)
	
	# Add preload chunks (slightly further away)
	for x in range(chunk_coords.x - PRELOAD_RADIUS, chunk_coords.x + PRELOAD_RADIUS + 1):
		for y in range(chunk_coords.y - PRELOAD_RADIUS, chunk_coords.y + PRELOAD_RADIUS + 1):
			var c = Vector2i(x, y)
			if not generated_chunks.has(c) and not generation_queue.has(c):
				generated_chunks[c] = true
				preload_queue.append(c)
	
	# Prioritze main generation queue
	if generation_queue.size() > 0:
		var next_chunk = generation_queue.pop_front()
		call_deferred("_generate_chunk_async", next_chunk)
	elif preload_queue.size() > 0:
		# Generate on preload chunk slowly during idle time
		var next_preload = preload_queue.pop_front()
		call_deferred("_generate_chunk_async", next_preload)
	
	
func _generate_chunk_async(chunk_coords: Vector2i) -> void:
	var start_x = chunk_coords.x * CHUNK_SIZE
	var start_y = chunk_coords.y * CHUNK_SIZE
	var ground_cells := []
	var cell_count := CHUNK_SIZE * CHUNK_SIZE
	
	for i in range(cell_count):
		var x = i % CHUNK_SIZE
		@warning_ignore("integer_division") var y = i / CHUNK_SIZE
		var world_x = start_x + x
		var world_y = start_y + y
		var cell := Vector2i(world_x, world_y)
		var noise_val: float = noise.get_noise_2d(world_x, world_y)
		
		# base water layer
		water_tileset.set_cell(cell, source_id, water_tiles.pick_random())
		 # ground overlay
		if noise_val >= 0.0:
			ground_cells.append(cell)
			
		# yeild every few cells to reduce stutter
		if i % CELLS_PER_FRAME == 0:
			await get_tree().process_frame
	
	# apply ground terrain connectivity in batches
	await _connect_ground_cells_in_batches(ground_cells)
	
	#generated_chunks.erase(chunk_coords)
	
func _connect_ground_cells_in_batches(cells: Array) -> void:
	var batch_size = CELLS_PER_FRAME
	for i in range(0, cells.size(), batch_size):
		var batch = cells.slice(i, i + batch_size)
		ground_tileset.set_cells_terrain_connect(batch, terrain_set, 1, false)
		await get_tree().process_frame

func _on_unit_dig_complete(target_pos: Vector2):
	var cell = ground_tileset.local_to_map(target_pos)
	ground_tileset.set_cell(Vector2i(cell.x, cell.y), -1)


## erase ground tile when user request to be cleared by selection ##
#func perform_dig(tile: Vector2i):
	#ground_tileset.erase_cell(tile)
	#if selection_manager.claimed_tiles.has(tile):
		#selection_manager.claimed_tiles.erase(tile)
		#selection_manager.queue_redraw()
	#if selection_manager.highlighted_tiles.has(tile):
		#selection_manager.highlighted_tiles.erase(tile)
		#selection_manager.queue_redraw()
		#selection_manager.highlighted_tiles.erase(tile)
		#selection_manager.queue_redraw()
	
func is_tile_reachable(tile: Vector2i) -> bool:
	return ground_tileset.get_cell_source_id(tile) != -1
