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
	#print("idle entered")
	animation_player.play("idle")
	selection_manager.idle_units.append(unit)
	if not unit.assigned_jobs:
		if selection_manager.highlighted_tiles:
			selection_manager.request_dig_job(unit)



func _update(_delta: float) -> void:
	
	
	
	if unit.assigned_jobs:
		selection_manager.idle_units.erase(unit)
		if unit.assigned_jobs[0] != unit.current_tile_pos:
			unit.move_to(ground.map_to_local(unit.assigned_jobs[0]))
		if unit.assigned_jobs[0] == unit.current_tile_pos:
			dispatch("start_digging")

	
	if unit.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch("move_to_target")
		
