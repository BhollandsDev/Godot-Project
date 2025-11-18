extends CharacterBody2D

class_name Unit

@onready var main = $"../../../Main"
@onready var nav_agent = $NavigationAgent2D
@onready var animation_player = $AnimationPlayer
@onready var map_generator = get_node("../../Map Generator")
@onready var idle_state: LimboState = $"Main State Machine/Idle State"
@onready var walking_state: LimboState = $"Main State Machine/Walking State"
@onready var digging_state: LimboState = $"Main State Machine/Digging State"

@onready var main_state_machine: LimboHSM = $"Main State Machine"
@onready var ground = get_node("../../Map Generator/ground")
@onready var selection_manager = get_node("../../Selection Draw")
var test := false
var assigned_jobs := []
@export var job_limit : int = 1


#set speed
@export var speed : int

# every unit has their own selection box when selected
var selection_rect : Rect2
var selection_width : int
var previous_position: Vector2
var current_tile_pos : Vector2i
var current_job: Vector2i = Vector2i.ZERO


var select_mode : bool = false:
	set(value):
		select_mode = value
		if value: # selecting will create selection box 
			selection_rect = Rect2(Vector2(-8, -8), Vector2(16, 16))
			selection_width = 1
		else: # deselecting will remove it
			selection_rect = Rect2(0, 0, 0, 0,)
			selection_width = 0
		queue_redraw() #update drawing
		
		
#setting the name to Unit
func _ready() -> void:
	previous_position = position
	nav_agent.avoidance_enabled = true
	initiate_state_machine()
	
	
func initiate_state_machine():
	main_state_machine.add_transition(idle_state, walking_state, "move_to_target")
	main_state_machine.add_transition(main_state_machine.ANYSTATE, idle_state, "state_ended")
	main_state_machine.add_transition(idle_state, digging_state, "start_digging")
	main_state_machine.initial_state = idle_state
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	

func set_previous_position(pos: Vector2):
	previous_position = pos
#unit selection box is getting drawn

func _draw():
	draw_rect(selection_rect, Color.GREEN, false, selection_width)

#get the next position through Navigation Agent
func _physics_process(delta: float) -> void:
	animation(delta)
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = round(direction * speed)
	###return if navigation is finished
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		current_tile_pos = ground.local_to_map(ground.to_local(position))
	_on_unit_moved()
	move_and_slide()
	#print(main_state_machine.get_active_state())
	#request_job()
	#print(current_job)
		#print("idle")
	print(self.name, assigned_jobs)
	
	
	
#func to select the unit
func select():
	select_mode = true
	
#func to deselect the unit
func deselect():
	select_mode = false

#clicking unit individually will turn on select mode
func _on_input_event(_viewport : Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_mode = true
			for unit in get_tree().get_nodes_in_group("Units"):
				#for unit in main.selected_units:
				if unit != self:
					unit.remove_from_group("Selected Units")
					unit.deselect()
				self.add_to_group("Selected Units")



func move_to(target_position):
	nav_agent.target_position = target_position


func animation(_delta):
	if velocity.length() > 0:
		#print(velocity)
		if velocity.x < 0:
			$Sprite2D.flip_h = true
		elif velocity.x > 0:
			$Sprite2D.flip_h = false
#
func _on_unit_moved():
	main.update_unit_position(previous_position, position)
	previous_position = position
	

func request_job():
	if test:
		
		if main_state_machine.get_active_state() == idle_state:
			if not current_job:
				var job = selection_manager.request_dig_job(self)
				if job != Vector2i.ZERO:
					current_job = job
					#print(name, " assigned jobs, ", current_job)
