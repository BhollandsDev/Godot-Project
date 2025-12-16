extends LimboState


#@onready var main_state_machine: LimboHSM = $".."
@onready var unit: CharacterBody2D = $"../.."

#@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animated_sprite: AnimatedSprite2D = $"../../Visuals/Sprite2D"
@onready var ground = get_node("/root/Main/Map Generator/ground")
#@onready var main = get_node("/root/Main")
#@onready var map_generator = get_node("/root/Main/Map Generator")
#@onready var selection_manager = get_node("/root/Main/Selection Draw")
var current_job_tile: Vector2i
var dig_timer: float = 0.0
var DIG_DURATION: float = 1.0 # Seconds to dig
var SAFE_ZONE_POS := Vector2(80,80) # The starting spawn area from Main.gd
var fail_counter : int = 0

func _enter() -> void:
	if unit.assigned_jobs.is_empty():
		dispatch("state_ended")
		return
	current_job_tile = unit.assigned_jobs[0]
	dig_timer = 0.0
	
	var my_tile = ground.local_to_map(unit.global_position)
	if is_neighbor(my_tile, current_job_tile):
		unit.velocity = Vector2.ZERO
		animated_sprite.play("Idle")
	else:
		var target_pos = find_best_stand_pos(current_job_tile)
		unit.move_to(target_pos)
		dispatch("move_to_target")

func _update(_delta: float) -> void:
	if not unit.assigned_jobs.is_empty():
		var my_tile = ground.local_to_map(unit.global_position)
		if is_neighbor(my_tile, current_job_tile):
			dig_timer += _delta
			if dig_timer >= DIG_DURATION:
				perform_dig()
	
	#if not unit.assigned_jobs:
		#dispatch("state_ended")


	
func perform_dig():
	var is_safe = PathfindingManager.check_reachability_after_removal(
		current_job_tile,
		unit.global_position,
		SAFE_ZONE_POS
	)
	if is_safe:
		JobManager.complete_dig_job(current_job_tile)
		unit.assigned_jobs.clear()
		dispatch("state_ended")
		
func is_neighbor(t1: Vector2i, t2: Vector2i) -> bool:
	var diff = (t1 - t2).abs()
	return diff.x <= 1 and diff.y <= 1 and t1 != t2
	
func find_best_stand_pos(target_tile: Vector2i) -> Vector2:
	var neighbors = [
		Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	
	var closest_pos = unit.global_position
	var min_dist = INF
	var found = false
	
	for offset in neighbors:
		var check_tile = target_tile + offset
		if PathfindingManager.is_walkable(check_tile):
			var world_pos = ground.map_to_local(check_tile)
			var dist = unit.global_position.distance_squared_to(world_pos)
			if dist < min_dist:
				min_dist = dist
				closest_pos = world_pos
				found = true
				
	return closest_pos
	
	
	
