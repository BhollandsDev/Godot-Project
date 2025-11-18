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
	selection_manager.idle_units.append(unit)

func _update(_delta: float) -> void:
	if unit.assigned_jobs:
		selection_manager.idle_units.erase(unit)
		if unit.assigned_jobs[0] != unit.current_tile_pos:
			unit.move_to(ground.map_to_local(unit.assigned_jobs[0]))
		if unit.assigned_jobs[0] == unit.current_tile_pos:
			dispatch("start_digging")
	
	
	#if unit.current_job:
		#if selection_manager.idle_units.has(unit):
			#selection_manager.idle_units.erase(unit)
		#if unit.current_job != unit.current_tile_pos:
#
			#unit.move_to(ground.map_to_local(unit.current_job))
		#elif unit.current_job == unit.current_tile_pos:
			#dispatch("start_digging")
	
	if unit.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch("move_to_target")
		
