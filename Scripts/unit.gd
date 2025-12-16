extends CharacterBody2D

#class_name Unit

@onready var main = $"../../../Main"
#@onready var nav_agent = $NavigationAgent2D
#@onready var animation_player = $AnimationPlayer
@onready var map_generator = get_node("../../Map Generator")
@onready var idle_state: LimboState = $"Main State Machine/Idle State"
@onready var walking_state: LimboState = $"Main State Machine/Walking State"
@onready var digging_state: LimboState = $"Main State Machine/Digging State"

@onready var main_state_machine: LimboHSM = $"Main State Machine"
@onready var ground = get_node("../../Map Generator/ground")
@onready var selection_manager = get_node("../../Selection Draw")
#var test := false
var assigned_jobs := []
@export var job_limit : int = 1

var current_path: PackedVector2Array
var current_path_index: int = 0
var final_target_pos: Vector2
#set speed
@export var speed : int

# every unit has their own selection box when selected
var selection_rect : Rect2
var selection_width : int
var previous_position: Vector2
var current_tile_pos : Vector2i
#var current_job: Vector2i = Vector2i.ZERO


var select_mode : bool = false:
	set(value):
		select_mode = value
		if value: # selecting will create selection box 
			selection_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))
			selection_width = 2
		else: # deselecting will remove it
			selection_rect = Rect2(0, 0, 0, 0,)
			selection_width = 0
		queue_redraw() #update drawing
		
		
#setting the name to Unit
func _ready() -> void:
	initiate_state_machine()
	SignalBus.unit_idle.emit(self)
	SignalBus.map_changed.connect(_on_map_changed)
	#PathfindingManager.map_changed.connect(_on_map_changed)
	#print(main_state_machine.get_active_state())
	
func initiate_state_machine():
	main_state_machine.add_transition(idle_state, walking_state, "move_to_target")
	main_state_machine.add_transition(main_state_machine.ANYSTATE, idle_state, "state_ended")
	main_state_machine.add_transition(idle_state, digging_state, "start_digging")
	main_state_machine.add_transition(walking_state, digging_state, "start_digging")
	main_state_machine.initial_state = idle_state
	main_state_machine.initialize(self)
	main_state_machine.set_active(true)
	

func set_previous_position(pos: Vector2):
	previous_position = pos
#unit selection box is getting drawn

func _draw():
	draw_rect(selection_rect, Color.GREEN, false, selection_width)
	_debug_draw_path_visual()

func _physics_process(_delta: float) -> void:
	_path_movement()
	_on_unit_moved()
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
				if unit != self:
					unit.remove_from_group("Selected Units")
					unit.deselect()
				self.add_to_group("Selected Units")

func move_to(target_position):
	#request path from pathmanager
	final_target_pos = target_position
	var new_path = PathfindingManager.get_path_route(global_position, target_position)
	if new_path.is_empty():
		velocity = Vector2.ZERO
		current_path = PackedVector2Array()
		return
	current_path = PathfindingManager.get_path_route(global_position, target_position)
	current_path_index = 0
	
#Updates occupied positons so they dont spawn ontop of eachother
func _on_unit_moved():
	main.update_unit_position(previous_position, position)
	previous_position = position

func _path_movement():
	#animation()
	var desired_velocity := Vector2.ZERO
	# Only runs if path existis
	if not current_path.is_empty():
		if current_path_index >= current_path.size():
			current_path = PackedVector2Array()
		else:
			
			var target_point = current_path[current_path_index]
			if global_position.distance_to(target_point) < 6.0:
				current_path_index +=1
				if current_path_index >= current_path.size():
					current_path = PackedVector2Array()
					current_tile_pos = ground.local_to_map(position)
				else:
					target_point = current_path[current_path_index]
			if not current_path.is_empty():
				desired_velocity = (target_point - global_position).normalized() * speed
				
	var seperation := Vector2.ZERO
	var nearby_units = get_tree().get_nodes_in_group("Units")
	
	for other in nearby_units:
		if other == self: continue
		var dist = global_position.distance_to(other.global_position)
		if dist < 25.0:
			if dist < 0.1: dist = 0.1
			var push_dir = (global_position - other.global_position).normalized()
			seperation += push_dir * (1.0 - dist / 25.0)
	
	var seperation_force = seperation * 200.0
	if seperation_force.length() > speed * 0.8:
		seperation_force = seperation_force.limit_length(speed * 0.8)
	
	velocity = desired_velocity + (seperation * 200.0)
	if selection_manager.path_visual_enable:
		queue_redraw()
		
func _debug_draw_path_visual():
	if selection_manager.path_visual_enable and not current_path.is_empty():
		if current_path_index >= current_path.size():
			return
		
		var points = PackedVector2Array()
		points.append(Vector2.ZERO)
		
		for i in range(current_path_index, current_path.size()):
			points.append(to_local(current_path[i]))
		
		if points.size() >= 2:
			draw_polyline(points, selection_manager.path_visual_line_color, selection_manager.path_visual_line_width)
		
func _on_map_changed(bad_cell: Vector2i):
	#print("Maped Changed")
	var my_cell = ground.local_to_map(global_position)
	if my_cell == bad_cell:
		print("EMERGENCY: Ground destroyed under unit!! Jumping to saftey.")
		#_emergency_escape(my_cell)
	
	if current_path.is_empty():
		return
	
	var path_affected = false
	
	for i in range(current_path_index, current_path.size()):
		var point_in_world = current_path[i]
		var point_in_grid = ground.local_to_map(to_local(point_in_world))
		if point_in_grid == bad_cell:
			path_affected = true
			break
	
	if path_affected:
		move_to(final_target_pos)

func assign_job(tile: Vector2i):
	assigned_jobs.append(tile)
	if main_state_machine.get_active_state() == idle_state:
		main_state_machine.dispatch("start_digging")
	
func clear_job():
	assigned_jobs.clear()
