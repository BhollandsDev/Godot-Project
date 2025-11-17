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
	print("job reached")
	if unit.current_job == unit.current_tile_pos:
		map_generator.perform_dig(unit.current_job)
		unit.current_job = Vector2i.ZERO
	if selection_manager.idle_units.has(unit):
			selection_manager.idle_units.erase(unit)
			
func _update(_delta: float) -> void:
	if unit.current_job == Vector2i.ZERO:
		dispatch("state_ended")
