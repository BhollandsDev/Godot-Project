extends LimboState

@onready var main_state_machine: LimboHSM = $".."
#@onready var unit: Unit = $"../.."
@onready var unit: CharacterBody2D = $"../.."

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var map_generator = get_node("/root/Main/Map Generator")
@onready var selection_manager = get_node("/root/Main/Selection Draw")


func _enter() -> void:
	animation_player.play("idle")
	

func _update(_delta: float) -> void:
	if unit.current_job:
		if unit.current_job != unit.current_tile_pos:
			#main.move_to_position(ground, unit.current_job)
			#main.move_to_job_pos(ground, unit.current_job)
			unit.move_to(ground.map_to_local(unit.current_job))
		elif unit.current_job == unit.current_tile_pos:
			dispatch("start_digging")
		#print("has job")
	#if selection_manager.highlighted_tiles.size() > 0:
		##print("job pos, ",unit.set_next_dig())
		##print("unit pos,",unit.current_tile_pos)
		#if  unit.set_next_dig() == unit.current_tile_pos:
			#map_generator.perform_dig(unit.set_next_dig())
		#elif unit.set_next_dig() != unit.current_tile_pos:
			#main.move_to_position(ground, unit.set_next_dig())
	#elif selection_manager.highlighted_tiles.size() <= 0:
		##print("empty")
		#pass
	#print(unit.name, unit.current_job)
	#if unit.assigned_jobs.size() > 0:
		#if unit.assigned_jobs[0] != unit.current_tile_pos:
			#main.move_to_position(ground, unit.assigned_jobs[0])
			##print(unit, " assigned jobs, ", unit.assigned_jobs)
		##dispatch("move_to_target")
		###print("job pos, ",unit.set_next_dig())
		###print("unit pos,",unit.current_tile_pos)
		#if  unit.assigned_jobs[0] == unit.current_tile_pos:
			##map_generator.perform_dig(unit.assigned_jobs[0])
			#unit.assigned_jobs.erase(unit.assigned_jobs[0])
		##elif selection_manager.set_next_dig() != unit.current_tile_pos:
			##main.move_to_position(ground, selection_manager.set_next_dig())
	##elif selection_manager.highlighted_tiles.size() <= 0:
		###print("empty")
	pass
	
	if unit.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch("move_to_target")
		
