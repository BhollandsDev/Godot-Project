extends Node
# Astar graph node
var astar  := AStar2D.new()

# Mapping between Vector2i (Grid Coords) and Astar ID (int)
var tile_to_id: Dictionary = {}
var next_id := 0

# Standard Neighbor offsets (Cardinal Direction + Diagnals)
const NEIGHBORS := [
	Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1 ,0), Vector2i(1, 0),
	Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
]

func _ready() -> void:
	# Optimize for large graphs
	astar.reserve_space(10000)
	
# --------------------------------------------------------
#      CHUNK GENERATION (Called by MapGenerator)
# --------------------------------------------------------

func add_walkable_cells(cells: Array[Vector2i]):
	for cell in cells:
		if tile_to_id.has(cell):
			continue # already exists
		#Create new
		var id := next_id
		next_id += 1
		tile_to_id[cell] = id
		
		# Add to astar graph (world position = cell * tilesize)
		astar.add_point(id, Vector2(cell) * 32)
		#connect existing neighbors
		_connect_to_neighbors(cell, id)
		
func _connect_to_neighbors(cell: Vector2i, id: int):
	for offset in NEIGHBORS:
		var neighbor_cell = cell + offset
		
		#if the neighbor exist in our graph, connect them
		if tile_to_id.has(neighbor_cell):
			var neighbor_id = tile_to_id[neighbor_cell]
			if offset.x != 0 and offset.y != 0:
				if not _is_walkable(cell + Vector2i(offset.x, 0)) or \
				not _is_walkable(cell + Vector2i(0, offset.y)):
					continue
			
			# bidirectional connection
			astar.connect_points(id, neighbor_id)

# --------------------------------------------------------
#                DIGGING & MODIFICATION
# --------------------------------------------------------

func set_tile_walkable(cell: Vector2i, walkable: bool):
	if not tile_to_id.has(cell):
		return # tile not loaded yet
	
	var id = tile_to_id[cell]
	#toggle the point 'disabled' means it acts like a wall.
	astar.set_point_disabled(id, not walkable)
	
# --------------------------------------------------------
#              UNIT PATHFINDING
# --------------------------------------------------------

func get_path_route(start_world: Vector2, end_world: Vector2) -> PackedVector2Array:
	var start_cell = Vector2i(start_world / 32.0)
	var end_cell = Vector2i(end_world / 32.0)
	
	if not tile_to_id.has(start_cell) or not tile_to_id.has(end_cell):
		return PackedVector2Array() #one of the points is invalid/ unload
	
	var start_id = tile_to_id[start_cell]
	var end_id = tile_to_id[end_cell]
	
	return astar.get_point_path(start_id, end_id)

func _is_walkable(cell: Vector2i) -> bool:
	return tile_to_id.has(cell) and not astar.is_point_disabled(tile_to_id[cell])
