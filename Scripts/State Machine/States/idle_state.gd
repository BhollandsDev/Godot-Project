extends LimboState

@onready var main_state_machine: LimboHSM = $".."
@onready var unit: CharacterBody2D = $"../.."
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var map_generator = get_node("/root/Main/Map Generator")
@onready var selection_manager = get_node("/root/Main/Selection Draw")
@onready var animated_sprite: AnimatedSprite2D = $"../../Visuals/Sprite2D"


func _enter() -> void:
	animated_sprite.play("Idle")

	if unit.velocity != Vector2.ZERO:
		dispatch("move_to_target")
