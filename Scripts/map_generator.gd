extends Node2D

@onready var tilemap: TileMapLayer = %"Main TileMap World"
var noise := FastNoiseLite.new()
## Tile Definitions

const TILE_GROUND = Vector2i(0,5)
const TILE_DEEP_WATER = Vector2i(3,4)
const TILE_FOREST = Vector2i(6,3)
const TILE_SHALLOW_WATER = Vector2i(5,0)
const TILE_SHORE_DIAG = Vector2i(1,0)
const TILE_SHORE_VERT = Vector2i(0,1)
const TILE_SHORE_CURV = Vector2i(3,0)
const TILE_SHALLOW_DEEP_WATER_DIAG = Vector2i(4,1)
const TILE_SHALLOW_DEEP_WATER_VERT = Vector2i(6,5)
const TILE_SHALLOW_DEEP_WATER_CURV = Vector2i(4,5)
const TILE_FOREST_GROUND_DIAG = Vector2i(6,7)
const TILE_FOREST_GROUND_VERT = Vector2i(5,4)
const TILE_FOREST_GROUND_CURV = Vector2i(5,6)

var tile_edges = {
	TILE_GROUND: {"top": 1, "right": 1, "bottom": 1, "left": 1},
	TILE_DEEP_WATER: {"top": 2, "right": 2, "bottom": 2, "left": 2},
	TILE_FOREST: {"top": 3, "right": 3, "bottom": 3, "left": 3},
	TILE_SHALLOW_WATER: {"top": 4, "right": 4, "bottom": 4, "left": 4},
	TILE_SHORE_DIAG: {"top": 1, "right": 4, "bottom": 4, "left": 1},
	TILE_SHORE_VERT: {"top": 5, "right": 1, "bottom": 5, "left": 4},
	TILE_SHORE_CURV: {"top": 4, "right": 4, "bottom": 5, "left": 1},
	TILE_SHALLOW_DEEP_WATER_DIAG: {"top": 4, "right": 2, "bottom": 2, "left": 4},
	TILE_SHALLOW_DEEP_WATER_VERT: {"top": 6, "right": 4, "bottom": 6, "left": 2},
	TILE_SHALLOW_DEEP_WATER_CURV: {"top": 4, "right": 4, "bottom": 6, "left": 2},
	TILE_FOREST_GROUND_DIAG: {"top": 3, "right": 1, "bottom": 1, "left": 3},
	TILE_FOREST_GROUND_VERT: {"top": 7, "right": 1, "bottom": 7, "left": 3},
	TILE_FOREST_GROUND_CURV: {"top": 3 , "right": 1, "bottom": 7, "left": 3}
}

# 1 tile = 32x32 pixels
# 1 chunk = 32x32 tiles

const CHUNK_SIZE := 32
var generated_chunks := {}
#var atlas_source_id: int
	# --- Keep track of which tiles are walkable ---
#var walkable_tiles := {0: true, 1: true, 2: false, 3: false}

func _ready() -> void:
	randomize()
	noise.seed = randi()
	
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
			var world_pos = Vector2i(start_x + x, start_y + y)
			var raw_noise = noise.get_noise_2d(world_pos.x, world_pos.y)
			const NOISE_MIN = 0.0
			const NOISE_MAX = 100.0
			var base_noise = NOISE_MIN + (raw_noise + 1.0 / 2.0) * (NOISE_MAX - NOISE_MIN)
			var tile_to_place: Vector2i
			#print(base_noise)
			if base_noise > 75.0 and base_noise < 100.0:
				tile_to_place = TILE_GROUND
			elif base_noise > 50.0 and base_noise < 75.0:
				tile_to_place = TILE_FOREST
			elif base_noise > 25.0 and base_noise < 50.0:
				tile_to_place = TILE_SHALLOW_WATER
			else:
				tile_to_place = TILE_DEEP_WATER
			
			tile_to_place = choose_tile_for_positions(world_pos, tile_to_place)
			
			#var transform = randomized_transform()
			tilemap.set_cell(world_pos, 0, tile_to_place, randomized_transform())
	generated_chunks[chunk_coords] = true
	
func randomized_transform():
	var raw_noise = RandomNumberGenerator.new()
	raw_noise.randomize()
	raw_noise.randi_range(1,5)
	var choice = raw_noise.randi_range(0,5)
	match choice:
		0:
			return 0
		1:
			return TileSetAtlasSource.TRANSFORM_FLIP_H
		2:
			return TileSetAtlasSource.TRANSFORM_FLIP_V
		3:
			return TileSetAtlasSource.TRANSFORM_TRANSPOSE
		4:
			return TileSetAtlasSource.TRANSFORM_TRANSPOSE |  TileSetAtlasSource.TRANSFORM_FLIP_H
		5:
			return TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V

func choose_tile_for_positions(pos: Vector2i, base_tile: Vector2i) -> Vector2i:
	var possible_tiles = [base_tile] + tile_edges.keys()
	#print(base_tile)
	var dirs = {
		"top": Vector2i(0, -1),
		"bottom": Vector2i(0, 1),
		"left": Vector2i(-1, 0),
		"right": Vector2i(1, 0)
	}
	for dir in dirs.keys():
		var neighbor_pos = pos + dirs[dir]
		var neighbor = tilemap.get_cell_atlas_coords(neighbor_pos)
		
		if neighbor != Vector2i(-1, -1):
			possible_tiles = possible_tiles.filter(func(t):
				return can_place_tile(t, neighbor,dir)
			)
		
		if possible_tiles.is_empty():
			return base_tile
	return possible_tiles.pick_random()
		
func can_place_tile(candidate: Vector2i, neighbor: Vector2i, direction: String) -> bool:
	if not tile_edges.has(candidate) or not tile_edges.has(neighbor):
		
		return true
		
	var opposite_dir = {
		"top": "bottom",
		"bottom": "top",
		"left": "right",
		"right": "left"
	}	
	var candidate_side = tile_edges[candidate][direction]
	var neighbor_side = tile_edges[neighbor][opposite_dir[direction]]
	return	 candidate_side == neighbor_side
	
