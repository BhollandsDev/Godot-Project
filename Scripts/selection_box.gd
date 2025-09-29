extends Control
var drawing = false
var start_pos : Vector2
var end_pos : Vector2
var width = 1



func _process(_delta: float) -> void:
	if drawing:
		queue_redraw()

func _draw():
	if  not drawing:
		return
	var rect = Rect2(start_pos, end_pos - start_pos).abs()
	draw_rect(rect, Color.RED, false)

func get_selection_rect() -> Rect2:
	return Rect2(start_pos, end_pos - start_pos).abs()
	
## Turns on rectangle drawing and draws rectangle drawing
func _draw_rect_clicked():
	drawing = true
	start_pos = get_viewport().get_mouse_position()
	end_pos = start_pos
	#get_selection_rect(UnitManager.select_in())
	
## Turns off rectangle drawing and clears rectangle from camera
func _draw_rect_released():
	drawing = false
	UnitManager.select_units(UnitManager.get_units())
	#get_units_in_rect(UnitManager.check_unit())
	queue_redraw()

func get_units_rect(units: Array) -> Array:
	var rect = get_selection_rect()
	var cam = get_viewport().get_camera_2d()
	var selected: Array = []
	for unit in units:
		var screen_pos = cam.world_to_screen(unit.global_position)
		if rect.has_point(screen_pos):
			selected.append(unit)
	return selected
		


#func get_units_in_rect(units: Array) -> Array:
	#var rect = get_selection_rect()
	#var selected: Array = []
	#for unit in units:
		#var screen_pos = get_viewport().get_camera_2d().unproject_position(unit.global_position)
		#if rect.has_point(screen_pos):
			#selected.append(unit)
	#return selected
