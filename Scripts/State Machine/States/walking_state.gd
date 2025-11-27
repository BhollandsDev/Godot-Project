extends LimboState


@onready var main_state_machine: LimboHSM = $".."
#@onready var unit: Unit = $"../.."
@onready var unit: CharacterBody2D = $"../.."

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var selection_manager = get_node("/root/Main/Selection Draw")


func _enter() -> void:
	#print("walking")
	animation_player.play("run")
	if unit.assigned_jobs:
		var target_pos = ground.map_to_local(unit.assigned_jobs[0])
		unit.move_to(target_pos)
	

func _update(_delta: float) -> void:
	if unit.assigned_jobs.is_empty():
		dispatch("state_ended")
		return
	if nav_agent.is_navigation_finished():
		dispatch("start_digging")
