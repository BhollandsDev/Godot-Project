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
	#print("idle")
	#print(unit.assigned_jobs)
	animation_player.play("idle")
	if unit.assigned_jobs.is_empty():
		if not JobManager.idle_units.has(unit):
			JobManager.idle_units.append(unit)
		SignalBus.unit_idle.emit(unit)
	else:
		dispatch("move_to_target")
		

func _update(_delta: float) -> void:
	if unit.assigned_jobs:
		dispatch("move_to_target")


func _exit() -> void:
	if JobManager.idle_units.has(unit):
		JobManager.idle_units.erase(unit)
