extends LimboState


@onready var main_state_machine: LimboHSM = $".."
#@onready var unit: Unit = $"../.."
@onready var unit: CharacterBody2D = $"../.."

#@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var selection_manager = get_node("/root/Main/Selection Draw")


func _enter() -> void:
	#print("walking")
	animation_player.play("run")
	if unit.assigned_jobs:
		unit.move_to_job(unit.assigned_jobs[0])

func _update(_delta: float) -> void:
	
		
	if unit.current_path.is_empty():
		if unit.assigned_jobs.is_empty():
			dispatch("state_ended")
		
		if not unit.assigned_jobs.is_empty():
			dispatch("start_digging")
