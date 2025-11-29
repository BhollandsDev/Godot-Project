extends LimboState


@onready var main_state_machine: LimboHSM = $".."
@onready var unit: CharacterBody2D = $"../.."

#@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var map_generator = get_node("/root/Main/Map Generator")
@onready var selection_manager = get_node("/root/Main/Selection Draw")



func _enter() -> void:
	distance_check_to_job()


func _update(_delta: float) -> void:
	
	
	if not unit.assigned_jobs:
		dispatch("state_ended")

func distance_check_to_job():
	var job_tile = unit.assigned_jobs[0]
	var unit_cell = ground.local_to_map(unit.global_position)
	var world_job_pos = ground.map_to_local(job_tile)
	#var grid_distance = Vector2(unit_cell - job_tile).abs().max_axis_index()
	var dist = unit.global_position.distance_to(world_job_pos)
	var is_close_enough = dist < 50.0
	var diff = (unit_cell - job_tile).abs()
	var is_neighbor = diff.x <= 1 and diff.y <= 1
	if not is_neighbor and not is_close_enough:
		print("Unit too far. Repositioning...")
		dispatch("move_to_target")
		return
	
	
	
	var dig_complete = await  JobManager.perform_dig(job_tile)
	if dig_complete and is_active():
		if not unit.assigned_jobs.is_empty():
			unit.assigned_jobs.erase(job_tile)
		dispatch("state_ended")
