extends LimboState

@onready var main_state_machine: LimboHSM = $".."
@onready var unit: Unit = $"../.."
@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
#@onready var main2 = 



func _enter() -> void:
	animation_player.play("idle")
	#print("idle entered")
	unit.current_tile_pos = unit.ground.local_to_map(ground.to_local(unit.position))
	#print(unit.current_tile_pos)
	
	if unit.current_job == unit.current_tile_pos:
		unit._on_reached_job_target()
		
func _process(delta: float) -> void:
	pass
	
	
func _update(delta: float) -> void:
	if unit.current_job:
		if unit.current_job != unit.current_tile_pos:
			main.move_to_position(ground, unit.current_job)
	
	
	if unit.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch("move_to_target")
		
	
		
		
