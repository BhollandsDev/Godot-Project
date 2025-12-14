extends LimboState


@onready var main_state_machine: LimboHSM = $".."
@onready var unit: CharacterBody2D = $"../.."
@onready var ground = get_node("/root/Main/Map Generator/ground")
@onready var main = get_node("/root/Main")
@onready var selection_manager = get_node("/root/Main/Selection Draw")
@onready var animated_sprite: AnimatedSprite2D = $"../../Visuals/Sprite2D"



func _enter() -> void:

	animated_sprite.play("Walking right")
	
func _update(_delta: float) -> void:
	var velocity = unit.velocity
	var dir = velocity.normalized()
	#print(dir)
	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("Walking right")
		animated_sprite.flip_h = dir.x < 0
	else:
		animated_sprite.flip_h = false
		if dir.y > 0:
			animated_sprite.play("Walking down")
		else:
			animated_sprite.play("Walking up")

		
		
		
	if unit.current_path.is_empty():
		dispatch("state_ended")
