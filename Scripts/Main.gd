extends Node2D

#@onready var ground = $"Map Generator/NavigationRegion2D/TileMapLayer"

@onready var units_container = $"Units Container"
#@onready var selection_box = $"UI/Menu/SelectionBox"

var start_position = Vector2.ZERO
var end_position = Vector2.ZERO


	
func _ready() -> void:
	UnitManager.spawn_parent = units_container
	#UnitManagerTesting.spawn_parent.global_position = Vector2(80, 80)
	#UnitManager.selection_box = $UI/Menu/SelectionBox
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		#selection_box._draw_rect_clicked()
		#
	#elif event is InputEventMouseMotion and selection_box.drawing:
		#selection_box.end_pos = get_viewport().get_mouse_position()
	#
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		#selection_box._draw_rect_released()
		
#func get_tile_pos(global_pos):
	#
	#var local_pos = ground.to_local(global_pos)
	#var tile_pos = ground.local_to_map(local_pos)
	#
	#
	#return tile_pos
	
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_pressed():
			#pass
			##test()

#func test():
	#var world_pos = get_global_mouse_position()
	#var camera_pos = get_viewport().get_mouse_position()
	#print("world position, ",world_pos,", camera position, ", camera_pos)
	#print(ground.position)
