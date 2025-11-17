extends LimboState


@onready var main_state_machine: LimboHSM = $".."
#@onready var unit: Unit = $"../.."
@onready var unit: CharacterBody2D = $"../.."

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")



func _enter() -> void:
	animation_player.play("run")

	
	

func _update(_delta: float) -> void:
	if unit.velocity == Vector2.ZERO:
		dispatch("state_ended")

		#print("moved finished")
