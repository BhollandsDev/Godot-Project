extends LimboState

@onready var main_state_machine: LimboHSM = $".."
@onready var unit: Unit = $"../.."
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func _enter() -> void:
	animation_player.play("idle")
	print("idle entered")
func _process(delta: float) -> void:
	pass
	
	
func _update(delta: float) -> void:
	if unit.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch("move_to_target")
		
	
		
		
