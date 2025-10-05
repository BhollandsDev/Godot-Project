extends Control
var drawing = false
var start_pos : Vector2
var end_pos : Vector2
var width = 3
var selection_rect: Rect2
@onready var camera = get_node("/root/Main/CameraController/Camera2D")

func _process(_delta: float) -> void:
	if drawing:
		queue_redraw()

func _draw():
	if drawing:	
		var rect_position = start_pos
		var rect_size = end_pos - start_pos
		if rect_size.x < 0:
			rect_position.x += rect_size.x
			rect_size.x = abs(rect_size.x)
		if rect_size.y < 0:
			rect_position.y += rect_size.y
			rect_size.y = abs(rect_size.y)
		selection_rect = Rect2(rect_position, rect_size)
		draw_rect(selection_rect, Color.RED, false, width)

func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if event.pressed:
				#start_pos = camera.get_screen_transform().affine_inverse() * get_viewport().get_mouse_position()
				#drawing = true
			#elif event.is_released:
				#end_pos = camera.get_screen_transform().affine_inverse() * get_viewport().get_mouse_position()
				#drawing = false
				#queue_redraw()
	#elif event is InputEventMouseMotion and drawing:
		#end_pos = camera.get_screen_transform().affine_inverse() * get_viewport().get_mouse_position()
		#queue_redraw()
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			
			start_pos = get_viewport().get_mouse_position()
			end_pos = start_pos
			drawing = true
			queue_redraw()
			print(camera)
		else:
			
			end_pos = get_viewport().get_mouse_position()
			drawing = false
			
			start_pos = Vector2.ZERO
			end_pos = Vector2.ZERO
			queue_redraw()
			
	elif event is InputEventMouseMotion and drawing:
		
		end_pos = get_viewport().get_mouse_position()
		queue_redraw()
		UnitManager.selected_rect = selection_rect
		
	
		
		
#func get_selection_rect() -> Rect2:
	#return Rect2(start_pos, end_pos - start_pos).abs()
	
## Turns on rectangle drawing and draws rectangle drawing
#func _draw_rect_clicked():
	#drawing = true
	#start_pos = get_viewport().get_mouse_position()
	#end_pos = start_pos
	
## Turns off rectangle drawing and clears rectangle from camera
#func _draw_rect_released():
	#drawing = false
	##var test: Array =[]
	##print(UnitManager.get_units_rect(test))
	#queue_redraw()

#func check_unit(units_array: Array) -> Array:
	#for unit in get_parent().get_tree().get_nodes_in_group("Unit"):
		#unit.deselect()
	##units_array.clear()
	#
	#for unit in get_parent().get_tree().get_nodes_in_group("Unit"):
		#if get_selection_rect().has_point(unit.global_position):
			#unit.select()
			#units_array.append(unit)
	#print(units_array)
	#return units_array
	#for unit in get_parent().get_tree().get_nodes_in_group("Unit"): # get every Unit nodes
		#if get_selection_rect().has_point(unit.global_position): # if units position is inside the select box
			#unit.select() #select unit
			#units_array.append(unit)
		#else:
			#unit.deselect() #deselect the unit if its not present in the selected_rect
	#print(units_array)
	#return units_array
## Helper to check units inside the rectangle
#func get_units_rect(selected: Array) -> Array:
	#var rect = get_selection_rect()
	##var selected: Array = []
	#
	#for unit in get_tree().get_nodes_in_group("Unit"):
		#if rect.has_point(unit.global_position):
			#selected.append(unit)
	#return selected

#func get_units_in_rect(units: Array) -> Array:
	#var rect = get_selection_rect()
	#var selected: Array = []
	#for unit in units:
		#var screen_pos = get_viewport().get_camera_2d().unproject_position(unit.global_position)
		#if rect.has_point(screen_pos):
			#selected.append(unit)
	#return selected
