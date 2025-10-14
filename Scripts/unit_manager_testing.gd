extends Node2D

var selection_box: Node = null

#vars for instancing Units
var target_scene = preload("res://Scenes/unit.tscn")
var spawn_parent: Node2D = null
@onready var static_view = $".."
var spawn_start = Vector2(80, 80)

var spawn_offset = Vector2(20, 20)
#var spawn_start_world = get_global_transform_with_canvas() * spawn_start
var units_per_row = 5
var occupied_positions: Array = []

var selected_units: Array



## Function to get formation, square root of the size of units
#func get_formation(tile_pos):
	#var formation = []
	#var unit_count = selected_units.size()
	#var formation_size = ceil(sqrt(unit_count))
	##loop over the tiles for the units position
	#var index = 0
	#for x in range(-formation_size / 2, formation_size / 2 + 1):
		#for y in range(-formation_size / 2, formation_size / 2 + 1):
			#if index < unit_count:
				#formation.append(tile_pos + Vector2i(x, y))
				#index += 1
			#else:
				#break #break out of loop when no units left in the array
	#return formation
	
##func to set position for every units from formation
#func move_to_position(layer : TileMapLayer, tile_pos):
	#var formation = get_formation(tile_pos)
	#for i in range(selected_units.size()):
		#selected_units[i].move_to(layer.map_to_local(formation[i]))
		##selected_units[i].move_to(layer.local_to_map(formation[i]))
func add_unit():
	

	var unit = target_scene.instantiate()
	
	#spawn_parent.global_position = Vector2(80, 80)
	#add_child(unit)
	spawn_parent.add_child(unit)
	unit.global_position = Vector2(80, 80)
	#spawn_parent.global_position = Vector2(80, 80)
	
	
#func position_occupied(pos: Vector2) -> bool:
	#for p in occupied_positions:
		#if p == pos:
			#return true
	#return false
#
#func update_unit_position(old_pos: Vector2, new_pos: Vector2):
	#occupied_positions.erase(old_pos)
	#occupied_positions.append(new_pos)
	
#func delete_selected_units():
	#var to_delete = selected_units.duplicate()
	#for unit in to_delete:
		#if is_instance_valid(unit):
			#unit.queue_free()
		#selected_units.clear()






	
