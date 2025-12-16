extends Node

@onready var map_generator = get_node("../Main/Map Generator")
#@onready var water = get_node("../Main/Map Generator/water")
@onready var ground = get_node("../Main/Map Generator/ground")
#@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
#@onready var camera := get_tree().get_nodes_in_group("MainCamera")
#@onready var user_interface := $"../User Interface/UI"
#@onready var tile_size : int = map_generator.TILE_SIZE_SETTER
#@onready var main = get_node("../Main")
@onready var selection_manager := get_node("../Main/Selection Draw")

#@onready var dig_timer = get_tree().create_timer(0.5,)

#var available_dig_jobs: Array = []
var available_dig_jobs: Dictionary = {}
var claimed_dig_jobs: Dictionary = {}
var dirt_inventory: int = 0
#var start_pos : Vector2
#var end_pos : Vector2

#var idle_units := []

#var highlighted_tiles: Array = []
#var claimed_tiles := {}

func _ready() -> void:
	SignalBus.unit_idle.connect(_on_unit_idle)
	


func add_dig_job(tile: Vector2i):
	if not available_dig_jobs.has(tile) and not claimed_dig_jobs.has(tile):
		available_dig_jobs[tile] = true
		selection_manager.draw_dig_tile_selection.append(tile)
		selection_manager.queue_redraw()
		
		_assign_jobs_to_idle_units()

func _on_unit_idle(unit):
	_try_assign_job(unit)


func _assign_jobs_to_idle_units():
	for unit in get_tree().get_nodes_in_group("Units"):
		if unit.main_state_machine.current_state == unit.idle_state:
			_try_assign_job(unit)
			

func _try_assign_job(unit):
	if available_dig_jobs.is_empty():
		return
		
	var best_tile = Vector2i.ZERO
	var min_dist = INF
	var found_job = false
	
	for tile in available_dig_jobs.keys():
		var world_pos = ground.map_to_local(tile)
		var dist = unit.global_position.distance_squared_to(world_pos)
		if dist < min_dist:
			min_dist = dist
			best_tile = tile
			found_job = true
	
	if found_job:
		available_dig_jobs.erase(best_tile)
		claimed_dig_jobs[best_tile] = unit
		unit.assign_job(best_tile)
		
func complete_dig_job(tile: Vector2i):
	ground. erase_cell(tile)
	PathfindingManager.set_tile_walkable(tile, false)
	
	dirt_inventory += 1
	print("Dig complete! Dirt Inventory: ", dirt_inventory)
	
	claimed_dig_jobs.erase(tile)
	if selection_manager.draw_dig_tile_selection.has(tile):
		selection_manager.draw_dig_tile_selection.erase(tile)
		selection_manager.queue_redraw()

func abort_job(tile: Vector2i, unit):
	if claimed_dig_jobs.has(tile):
		claimed_dig_jobs.erase(tile)
		available_dig_jobs[tile] = true
		unit.clear_job()
		_assign_jobs_to_idle_units()
