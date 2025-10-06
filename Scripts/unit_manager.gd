extends Node2D

var selection_box: Node = null

#vars for instancing Units
var target_scene = preload("res://Scenes/unit.tscn")
var spawn_parent: Node2D = null

var spawn_start = Vector2(80, 80)
var spawn_offset = Vector2(20, 20)
var units_per_row = 5
var occupied_positions: Array = []
#var selected_rect: Rect2:
	#set(value):
		#selected_rect = value
		#check_unit()
		
		#print(selected_units)
		#print(selected_rect)
#var to store position and size of selection box
#var selected_rect : Rect2:
	#set(value):
		#selected_rect = value
		#check_unit() #will be called with any change of selection
#array to store every selected unit
#var units: Array = []
var selected_units: Array
#func to filter Units with selection box
#func register_unit(unit: Node) -> void:
	#if not units.has(unit):
		#units.append(unit)
		#
#func unregister_unit(unit: Node) -> void:
	#units.erase(unit)

#func get_units() -> Array:
	#return units
	
#func select_units(units: Array) -> void:
	#if selection_box == null:
		#return
	#selected_units = selection_box.get_units_in_rect(get_units())
	#print("Selected units: ", selected_units)
	
	
#func check_unit():
	#var rect = selected_rect.abs()
	##print(rect)
	#for unit in get_parent().get_tree().get_nodes_in_group("Unit"):
		#var unit_sprite: Sprite2D = unit.get_node("Sprite2D")
		#var tex_size = unit_sprite.texture.get_size() * unit_sprite.scale
		#var unit_rect = Rect2(unit.global_position - tex_size / 2, tex_size)
		##print(unit.name, " ", unit_rect )
		#print("Selection:", rect, " | Unit:", unit_rect)
		#if rect.intersects(unit_rect):
			#print("Selecting ", unit.name)
			#unit.select()
			#selected_units.append(unit)
	#print(selected_units)
	

## Function to get formation, square root of the size of units
func get_formation(tile_pos):
	var formation = []
	var unit_count = selected_units.size()
	var formation_size = ceil(sqrt(unit_count))
	#loop over the tiles for the units position
	var index = 0
	for x in range(-formation_size / 2, formation_size / 2 + 1):
		for y in range(-formation_size / 2, formation_size / 2 + 1):
			if index < unit_count:
				formation.append(tile_pos + Vector2i(x, y))
				index += 1
			else:
				break #break out of loop when no units left in the array
	return formation
	
##func to set position for every units from formation
func move_to_position(layer : TileMapLayer, tile_pos):
	var formation = get_formation(tile_pos)
	for i in range(selected_units.size()):
		selected_units[i].move_to(layer.map_to_local(formation[i]))
		
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
		if not position_occupied(positions):
			break
		index += 1
	unit.position = positions
	spawn_parent.add_child(unit)
	occupied_positions.append(positions)
	if unit.has_method("set_previous_position"):
		unit.set_previous_position(positions)
	print ("Added Unit at ", unit.position)
	unit.position = positions
	
func position_occupied(pos: Vector2) -> bool:
	for p in occupied_positions:
		if p == pos:
			return true
	return false

func update_unit_position(old_pos: Vector2, new_pos: Vector2):
	occupied_positions.erase(old_pos)
	occupied_positions.append(new_pos)
	
func delete_selected_units():
	var to_delete = selected_units.duplicate()
	for unit in to_delete:
		if is_instance_valid(unit):
			unit.queue_free()
		selected_units.clear()

#func select_units(selection_box: Control) -> void:
	#if not selection_box:
		#return
	#selected_units = selection_box.get_units_rect()
	#print("Selected units:", selected_units)
#func select_in(group):
	#for unit in get_tree().get_nodes_in_group("Unit"):
		#if unit in group:
			#unit.select()
		#else:
			#unit.deselect()
			
#func get_units_rect(selected: Array) -> Array:
	#var rect = selection_box.get_selection_rect()
	##var selected: Array = []
	#
	#for unit in get_tree().get_nodes_in_group("Unit"):
		#
		#if rect.has_point(unit.global_position):
			#selected.append(unit)
			#print(selected)
	#return selected
