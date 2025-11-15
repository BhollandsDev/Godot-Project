extends CharacterBody2D

class_name Unit

@onready var main = $"../../../Main"
@onready var nav_agent = $NavigationAgent2D
@onready var animation_player = $AnimationPlayer
@onready var map_generator = get_node("../../Map Generator")

@onready var idle_state: LimboState = $"Main State Machine/Idle State"
@onready var walking_state: LimboState = $"Main State Machine/Walking State"
@onready var main_state_machine: LimboHSM = $"Main State Machine"
@onready var ground = get_node("../../Map Generator/ground")
@onready var selection_manager = get_node("../../Selection Draw")




var main_sm : LimboHSM
#set speed
@export var speed : int
# every unit has their own selection box when selected
var selection_rect : Rect2
var selection_width : int
var previous_position: Vector2
var current_tile_pos : Vector2i
#var state := "idle"
#var dig_target : Vector2
#var dig_hits : int = 0
#const DIG_HITS_REQUIRED : int = 5

## Jobs assignment
var current_job := Vector2i(0, 0)

#setter flag variable for selection of unit
#@onready var selection_manager: Node2D = $"Selection Draw"

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
	
	main_state_machine.initial_state = idle_state
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	

func set_previous_position(pos: Vector2):
	previous_position = pos
#unit selection box is getting drawn
func _draw():
	draw_rect(selection_rect, Color.GREEN, false, selection_width)
	
#func _process(delta: float) -> void:
	#
	#print(current_job)
	
#get the next position through Navigation Agent
func _physics_process(delta: float) -> void:
##	#	return if navigation is finished
	#current_tile_pos = ground.local_to_map(ground.to_local(position))
	animation(delta)
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = round(direction * speed)
	#if current_job:
			#main.move_to_position(ground, current_job)
			#if current_job == current_tile_pos:
				#print("matches")
	

	
		
		
	on_move_finished()
	
	move_and_slide()
	
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
				#main.selected_units = [self] #update the selected unit from the Unit manger
				self.add_to_group("Selected Units")


#func to set target position
func move_to(target_position):
	nav_agent.target_position = target_position

func on_move_finished():
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if not current_job:
			current_job = get_next_dig_job()

#flip the sprite in the direction of velocity
func animation(_delta):
	if velocity.length() > 0:
		#print(velocity)
		if velocity.x < 0:
			$Sprite2D.flip_h = true
		elif velocity.x > 0:
			$Sprite2D.flip_h = false

func _on_unit_moved():
	main.update_unit_position(previous_position, position)
	previous_position = position
	

	

func get_next_dig_job() -> Vector2i:
	
	if selection_manager.tile_jobs.dig != null:
		for tile in selection_manager.tile_jobs.dig:
			 
			return tile
		return Vector2i(0,0)
	else:
		return Vector2i(0,0)

func _on_reached_job_target():
	if current_job:
		#print(selection_manager.tile_jobs.dig)
		for tile in selection_manager.tile_jobs.dig:
			current_job = tile
			map_generator.perform_dig(current_job)
			selection_manager.highlighted_tiles.erase(current_job)
			selection_manager.queue_redraw()
			selection_manager.tile_jobs.dig.erase(current_job)
			if selection_manager.tile_jobs.dig == []:
				#print(selection_manager.tile_jobs.dig)
				current_job = Vector2i(0 , 0)
			#print(selection_manager.tile_jobs.dig)
	
	
