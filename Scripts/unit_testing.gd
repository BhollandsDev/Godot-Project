extends CharacterBody2D
@onready var nav_agent = $NavigationAgent2D
@onready var animation_player = $AnimationPlayer
@onready var static_view = $"../.."
#set speed
@export var speed = 100
# every unit has their own selection box when selected
var selection_rect : Rect2
var selection_width : int
var previous_position: Vector2
#setter flag variable for selection of unit
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
	#add_to_group("Unit")
	name = "Unit"
	connect("tree_exited", Callable(self, "_on_tree_exited"))
	previous_position = position
	nav_agent.avoidance_enabled = true
	
func set_previous_position(pos: Vector2):
	previous_position = pos
#unit selection box is getting drawn
func _draw():
	draw_rect(selection_rect, Color.GREEN, false, selection_width)
	
	#var test := true
	#if test == true:
		#var test_screen = static_view
		##var testrect_pos =  Vector2(80, 80)
		#test_screen.position = Vector2(80, 80)
		#var testrect_size = Vector2(10, 10)
		#draw_rect(Rect2(test_screen.position,testrect_size), Color.GREEN, false, 3)

#get the next position through Navigation Agent
func _physics_process(delta: float) -> void:
#	return if navigation is finished
	if nav_agent.is_navigation_finished():
		#play idle when navigation stops
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		return
	#call animation flip function
	animation(delta)
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position). normalized()
	velocity = round(direction * speed)
	#print(velocity)
	move_and_slide()
	if position != previous_position:
		_on_unit_moved()
#func to select the unit
func select():
	select_mode = true
	
#func to deselect the unit
func deselect():
	select_mode = false

#clicking unit individually will turn on select mode
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_mode = true
			for unit in UnitManagerTesting.selected_units:
				if unit != self:
					unit.deselect()
			UnitManagerTesting.selected_units = [self] #update the selected unit from the Unit manger

#func to set target position
func move_to(target_position):
	nav_agent.target_position = target_position
#moving will play running animation
	animation_player.play("run")

#flip the sprite in the direction of velocity
func animation(_delta):
	if velocity.length() > 0:
		if velocity.x < 0:
			$Sprite2D.flip_h = true
		elif velocity.x > 0:
			$Sprite2D.flip_h = false

func _on_tree_exited():
	if self in UnitManagerTesting.selected_units:
		UnitManagerTesting.selected_units.erase(self)
func _on_unit_moved():
	UnitManagerTesting.update_unit_position(previous_position, position)
	previous_position = position
	
func _on_stop_moving():
	set_physics_process(false)
