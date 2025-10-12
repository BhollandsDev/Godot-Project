extends Node2D

@export var speed: float = 400.0  # pixels per second
@export var scroll_speed: float = 400.0 # Edge scroll speed
@export var edge_dist: int = 1       # Pixels from screen edge to trigger scrolling
@onready var camera: Camera2D = $Camera2D
#@export var camera_var: Camera2D = $Camera2D
var edge_scroll: bool 

func _ready() -> void:
	add_to_group("camera_controller")
func _process(delta: float) -> void:
	move_camera(delta)

	# --- Main camera movement handler ---
func move_camera(delta: float) -> void:
	var move := Vector2.ZERO
	move += get_keyboard_input()
	move += get_edge_scroll_input()
	if move != Vector2.ZERO:
		camera.position += move.normalized() * scroll_speed * delta
		
	# --- Keybaord movement ---
func get_keyboard_input() -> Vector2:
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	return input_dir
		
	# --- Edge scrolling movement ---
func get_edge_scroll_input() -> Vector2:
	if not edge_scroll:
		return Vector2.ZERO
	#if edge_scroll == true:
	var move := Vector2.ZERO
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x <= edge_dist:
		move.x -= 1
	elif mouse_pos.x >= viewport_size.x - edge_dist:
		move.x += 1
	if mouse_pos.y <= edge_dist:
		move.y -= 1
	elif mouse_pos.y >= viewport_size.y - edge_dist:
		move.y += 1
	return move

	

	
