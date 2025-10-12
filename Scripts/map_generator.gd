extends Node2D

@onready var tilemap: TileMapLayer = $NavigationRegion2D/TileMapLayer
var noise := FastNoiseLite.new()

const CHUNK_SIZE := 64
var generated_chunks := {}
var atlas_source_id: int
	# --- Keep track of which tiles are walkable ---
var walkable_tiles := {0: true, 1: true, 2: false, 3: false}

func _ready() -> void:
	
	noise.seed = randf()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		# --- get the atlas source ---
	#var sources = tilemap.tile_set.get_source_id(0)
	#atlas_source_id = sources
	generate_chunk(Vector2i(0, 0))
	




func _process(_delta: float) -> void:
	var camera_pos = get_viewport().get_camera_2d().position
	var tile_size = tilemap.tile_set.tile_size
	var chunk_coords = Vector2i(
		floor(camera_pos.x / (CHUNK_SIZE * tile_size.x)),
		floor(camera_pos.y / (CHUNK_SIZE * tile_size.y))
	)
	
	for x in range(chunk_coords.x - 1, chunk_coords.x + 2):
		for y in range(chunk_coords.y - 1, chunk_coords.y + 2):
			var c = Vector2i(x, y)
			if not generated_chunks.has(c):
				generate_chunk(c)
	
func generate_chunk(chunk_coords: Vector2i) -> void:
	var start_x = chunk_coords.x * CHUNK_SIZE
	var start_y = chunk_coords.y * CHUNK_SIZE
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = start_x + x
			var world_y = start_y + y 
			var raw_noise = noise.get_noise_2d(world_x, world_y)
			#print("raw noise value", raw_noise)
			var normalized_noise = (raw_noise + 1.0) / 2.0
			#print("normalized noise", normalized_noise)
			var min_range = 0.0
			var max_range = 100.0
			var custom_range_noise = min_range + normalized_noise * (max_range - min_range)
			var atlas_coords := Vector2i(0, 0) 
			#print(custom_range_noise)
			if custom_range_noise > 65.0 and custom_range_noise < 100.00:
				atlas_coords = Vector2i(0, 1) # --- Forest (not walkable) ---
			elif custom_range_noise > 50.0 and custom_range_noise < 65.0:
				atlas_coords = Vector2i(0, 0) # --- Ground (walkable) ---
			elif custom_range_noise < 50.0 and custom_range_noise > 35.0:
				atlas_coords = Vector2i(1, 0) # --- Shore (walkable) ---
			elif custom_range_noise <  35.0 and custom_range_noise > 0.0:
				atlas_coords = Vector2i(1, 1) # --- Deep water (not walkable) ---
			
			tilemap.set_cell(Vector2i(world_x, world_y), 0, atlas_coords)
	generated_chunks[chunk_coords] = true
	
