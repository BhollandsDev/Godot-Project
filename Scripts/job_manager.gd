extends Node

#@onready var map_generator = get_node("../Map Generator")
@onready var water = get_node("../Main/Map Generator/water")
@onready var ground = get_node("../Main/Map Generator/ground")
#@onready var units_container := get_tree().get_first_node_in_group("UnitsContainer")
#@onready var camera := get_tree().get_nodes_in_group("MainCamera")
#@onready var user_interface := $"../User Interface/UI"
#@onready var tile_size : int = map_generator.TILE_SIZE_SETTER
@onready var main = get_node("../Main")
@onready var selection_manager := get_node("../Main/Selection Draw")

#@onready var dig_timer = get_tree().create_timer(0.5,)

var available_dig_jobs: Array = []
var claimed_dig_jobs: Dictionary = {}

var start_pos : Vector2
var end_pos : Vector2

var idle_units := []

#var highlighted_tiles: Array = []
var claimed_tiles := {}

func _ready() -> void:
	SignalBus.unit_idle.connect(_assign_job_to_unit)
	
	
	pass

#func _process(delta: float) -> void:
	#print(idle_units)
	#print(unit.assigned_jobs)

func _assign_job_to_unit(unit):
	if available_dig_jobs.is_empty():
		return
	var best_job_index = -1
	var min_dist = INF
	
	for i in range(available_dig_jobs.size()):
		var tile = available_dig_jobs[i]
		var dist = unit.global_position.distance_to(ground.map_to_local(tile))
		if dist < min_dist:
			min_dist = dist
			best_job_index = i
			
	if best_job_index != -1:
		var tile = available_dig_jobs[best_job_index]
		unit.assigned_jobs.append(tile)
		claimed_dig_jobs[tile] = unit
		available_dig_jobs.remove_at(best_job_index)
	#selection_manager.claimed_tiles = claimed_dig_jobs
	selection_manager.queue_redraw()


func perform_dig(tile: Vector2i) -> bool:
	await get_tree().create_timer(0.5).timeout
	for unit in get_tree().get_nodes_in_group("Units"):
		var unit_cell = ground.local_to_map(unit.global_position)
		if unit_cell == tile:
			print("Dig Aborted: Unit is standing on the target")
			return false

	ground.erase_cell(tile)
	
	PathfindingManager.set_tile_walkable(tile, false)
	
	
	if selection_manager.draw_dig_tile_selection.has(tile):
		selection_manager.draw_dig_tile_selection.erase(tile)
		selection_manager.queue_redraw()
		
	if claimed_dig_jobs.has(tile):
		claimed_dig_jobs.erase(tile)
		selection_manager.queue_redraw()
	return true

func _match_jobs_to_units():
	
	for i in range(idle_units.size() -1, -1, -1):
		if available_dig_jobs.is_empty():
			break
		var unit = idle_units[i]
		var best_job_index = _find_closest_job_index(unit)
		
		if best_job_index != -1:
			var tile = available_dig_jobs[best_job_index]
			unit.assigned_jobs.append(tile)
			claimed_dig_jobs[tile] = unit
			available_dig_jobs.remove_at(best_job_index)
			idle_units.remove_at(i)
			
	selection_manager.queue_redraw()
		
		
func _find_closest_job_index(unit: Node) -> int:
	var best_index = -1
	var min_dist = INF
	var unit_pos = unit.global_position
	
	for i in range(available_dig_jobs.size()):
		var tile = available_dig_jobs[i]
		var dist = unit_pos.distance_squared_to(ground.map_to_local(tile))
		if dist < min_dist:
			min_dist = dist
			best_index = i 
	return best_index
