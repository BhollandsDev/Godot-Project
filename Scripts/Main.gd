extends Node2D


@onready var units_container = $"Units Container"
@onready var selection_manager := get_node("../Main/Selection Draw")
@onready var ground = get_node("../Main/Map Generator/ground")

var start_position = Vector2.ZERO
var end_position = Vector2.ZERO

var target_scene = preload("res://Scenes/unit.tscn")
var spawn_parent: Node2D = null

var spawn_start = Vector2(80, 80)
var spawn_offset = Vector2(20, 20)

var units_per_row = 5
var occupied_positions: Array = []


#var path_visualization_enable : bool
#var path_visualization_custom_color_enable: bool
#var path_visualization_color : Color
#var path_line_width : float 


func _ready() -> void:
	spawn_parent = units_container
	
	
func add_unit():
	if not target_scene or not spawn_parent:
		push_error("UnitManger: target_scene or spawn_parent not set")
		return
	var unit = target_scene.instantiate()
	var index = 0
	var positions: Vector2
	while true:
		@warning_ignore("integer_division")
		var row = int(index / units_per_row)
		var col = index % units_per_row
		
		positions = spawn_start + Vector2(spawn_offset.x * col, spawn_offset.y * row)
		
		var is_occupied = position_occupied(positions)
		var cell_coords = ground.local_to_map(positions)
		var is_land = ground.get_cell_source_id(cell_coords) != -1
		if not is_occupied and is_land:
			break
		
		
		#if not position_occupied(positions):
			#break
		index += 1
	unit.position = positions 
	spawn_parent.add_child(unit)
	unit.name = "Unit_%s" % str(spawn_parent.get_child_count())
	occupied_positions.append(positions)
	if unit.has_method("set_previous_position"):
		unit.set_previous_position(positions)
	
	#unit.position = positions
	#unit.nav_agent.debug_enabled = path_visualization_enable
	#unit.nav_agent.debug_use_custom = path_visualization_custom_color_enable
	#unit.nav_agent.debug_path_custom_color = path_visualization_color
	#unit.nav_agent.debug_path_custom_line_width = path_line_width

func position_occupied(pos: Vector2) -> bool:
	for p in occupied_positions:
		if p == pos:
			return true
	return false
	
func move_to_position(layer : TileMapLayer, tile_pos):
	var selected_units = selected_units_group(get_tree().get_nodes_in_group("Selected Units"))
	var formation = get_formation(tile_pos)
	for i in range(selected_units.size()):
		selected_units[i].move_to(layer.map_to_local(formation[i]))
		
func get_formation(tile_pos):
	var selected_units = selected_units_group(get_tree().get_nodes_in_group("Selected Units"))
	var formation = []

	var unit_count = selected_units.size()
	var formation_size = ceil(sqrt(unit_count))

	var index = 0
	for x in range(-formation_size / 2, formation_size / 2 + 1):
		for y in range(-formation_size / 2, formation_size / 2 + 1):
			if index < unit_count:
				formation.append(tile_pos + Vector2i(x, y))
				index += 1
			else:
				break #break out of loop when no units left in the array
	return formation
	
func selected_units_group(units_group):
	if units_group == null:
		return []
	else:
		return units_group

func update_unit_position(old_pos: Vector2, new_pos: Vector2):
	occupied_positions.erase(old_pos)
	occupied_positions.append(new_pos)
	
func delete_selected_units():
	for unit in get_tree().get_nodes_in_group("Selected Units"):
		if is_instance_valid(unit):
			occupied_positions.erase(unit.position)
			print(selection_manager)
			selection_manager.idle_units.erase(unit)
			unit.queue_free()

func is_point_on_navmap(point: Vector2, max_distance: float = 6.0) -> bool:
	var map_rid: RID = get_world_2d().get_navigation_map()
	var closest: Vector2 = NavigationServer2D.map_get_closest_point(map_rid, point)
	return closest.distance_to(point) <= max_distance
