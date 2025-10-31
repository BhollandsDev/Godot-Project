extends Node2D




@onready var water_tileset: TileMapLayer = $water
@onready var ground_tileset: TileMapLayer = $ground
@onready var ground_2_tileset: TileMapLayer = $ground2



@export var noise := FastNoiseLite.new()


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

#var ground_tiles := [
	#Vector2i(2,1),
	#Vector2i(3,1),
	#Vector2i(4,1),
	##Vector2i(4,3)
	##Vector2i(4,2),
	##Vector2i(1,3)
#]

const TILE_SIZE_SETTER := 32

const CHUNK_SIZE := 32
var generated_chunks := {}


func _ready() -> void:
	randomize()
	
	#noise = noise_text.noise
	noise.seed = randi()
	
	
func _process(_delta: float) -> void:
	var camera_pos = get_viewport().get_camera_2d().position
	var tile_size = water_tileset.tile_set.tile_size
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
			var cell := Vector2i(world_x, world_y)
			var noise_val: float = noise.get_noise_2d(world_x,world_y)
			water_tileset.set_cell(cell, source_id, water_tiles.pick_random())
			if noise_val >= 0.0:
				ground_tiles_array.append(Vector2i(world_x,world_y))
				
	ground_tileset.set_cells_terrain_connect(ground_tiles_array,terrain_set, ground_terrain_int,false)
		
	generated_chunks[chunk_coords] = true
