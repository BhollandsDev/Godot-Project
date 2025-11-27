extends LimboState


@onready var main_state_machine: LimboHSM = $".."
@onready var unit: CharacterBody2D = $"../.."

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var map_generator = get_node("/root/Main/Map Generator")
@onready var selection_manager = get_node("/root/Main/Selection Draw")



func _enter() -> void:
	#print("digging")
	var dig_complete = await JobManager.perform_dig(unit.assigned_jobs[0])
	if dig_complete:
		unit.assigned_jobs.erase(unit.assigned_jobs[0])
		dispatch("state_ended")
			
func _update(_delta: float) -> void:
	
	
	if not unit.assigned_jobs:
		dispatch("state_ended")
