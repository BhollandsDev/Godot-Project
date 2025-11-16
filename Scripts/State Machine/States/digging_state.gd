extends LimboState


@onready var main_state_machine: LimboHSM = $".."
@onready var unit: Unit = $"../.."
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")



func _enter() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	

func _update(delta: float) -> void:
	pass
