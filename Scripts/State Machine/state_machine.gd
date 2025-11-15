extends LimboHSM
class_name State_Machine

#@onready var idle: LimboState = $Idle
#@onready var walking: LimboState = $Walking
@onready var nav_agent: NavigationAgent2D = $"../NavigationAgent2D"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var unit: CharacterBody2D = $".."


func _ready() -> void:
	initiate_state_machine()
	


func initiate_state_machine():
	 #= LimboHSM.new()
	#add_child(main_sm)
	
	#idle = call_on_enter(idle_start).call_on_update(idle_update)
	#walking = call_on_enter(walking_start).call_on_update(walking_update)
	var idle_state = LimboState.new().named("Idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walking_state = LimboState.new().named("Walking").call_on_enter(walking_start).call_on_update(walking_update)
	add_child(idle_state)
	add_child(walking_state)
	
	#add_transition(idle, walking, &"move_to_target")
	#add_transition(ANYSTATE, idle, &"state_ended")
	add_transition(idle_state, walking_state, &"move_to_target")
	add_transition(ANYSTATE, idle_state, &"state_ended")
	initial_state = idle_state
	initialize(self)
	set_active(true)
	
	
func idle_start():
	animation_player.play("idle")
	
	
func idle_update(delta: float):
	if nav_agent.velocity.x != 0 or not nav_agent.is_navigation_finished():
		dispatch(&"move_to_target")
		
		
func walking_start():
	animation_player.play("run")

	
func walking_update(delta: float):
	#on_move_finished()
	if nav_agent.velocity == Vector2(0, 0):
		dispatch(&"state_ended")
		if unit.current_job:
			unit._on_reached_job_target()
		
		print("moved finished")
		#_on_reached_job_target()
