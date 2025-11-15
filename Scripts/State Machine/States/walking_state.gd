extends LimboState


@onready var main_state_machine: LimboHSM = $".."
@onready var unit: Unit = $"../.."
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func _enter() -> void:
	animation_player.play("run")
	print("walking entered")
func _process(delta: float) -> void:
	pass
	

func _update(delta: float) -> void:
	
	#on_move_finished()
	if unit.velocity == Vector2.ZERO:
		dispatch("state_ended")
		if unit.current_job:
			unit._on_reached_job_target()
		
		print("moved finished")
		#_on_reached_job_target()
	
