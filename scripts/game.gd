extends Node2D

var camera_speed = 512
var gold = 56

const SELECTION_MODE_DEFAULT = 0
const SELECTION_MODE_GRAB = 1

var selected_room = null 
var selection_mode = SELECTION_MODE_DEFAULT
var time_selection_clicked = 0

var room_buy_button_scene = preload("res://scenes/room_buy_button.tscn")
var room_scene = preload("res://scenes/room.tscn")

# Creates a room, puts it in the right place.
func new_room():
	var room = room_scene.instantiate()
	
	$Rooms.add_child(room)
	
	return room

func set_selected_room(new):
	if selected_room:
		selected_room.modulate = Color(1, 1, 1, 1)
	
	selected_room = new
	new.modulate = Color(1.2, 1.2, 1.2, 1)
	
# Checks if the currently-selected room (at the cursor) is valid.
func is_valid_room_position():
	for n in $Cursor/InsideCheck.get_overlapping_areas():
		if n.get_parent() != selected_room:
			return false
			
	for n in $Cursor/BelowCheck.get_overlapping_bodies():
		if n.get_name() == "TileMapLayer":
			return true
			
	for n in $Cursor/BelowCheck.get_overlapping_areas():
		if n.get_name() == "Area":
			return true
			
	return false

func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_up"):
		$Camera2D.position.y -= delta * camera_speed
	if Input.is_action_pressed("camera_down"):
		$Camera2D.position.y += delta * camera_speed
		
	$Cursor.position.x = (roundi(get_global_mouse_position().x + 64) / 128) * 128 
	$Cursor.position.y = (roundi(get_global_mouse_position().y - 64) / 128) * 128
	
	$UI/Control/Gold.text = str(gold) + " GOLD"
	
	if Input.is_action_just_pressed("select"):
		for n in $Rooms.get_children():
			if n.hovered:
				set_selected_room(n)
	elif Input.is_action_pressed("select"):
		if selection_mode == SELECTION_MODE_GRAB:
			selected_room.position = $Cursor.position
			if is_valid_room_position():
				selected_room.modulate = Color(1.4, 1.4, 1.4, 1)
			else:
				selected_room.modulate = Color(1, 0, 0, 1)
				
		if selected_room and selected_room.hovered:
			time_selection_clicked += delta
			selection_mode = SELECTION_MODE_GRAB
	else:
		time_selection_clicked = 0
		if selected_room:
			if selection_mode == SELECTION_MODE_GRAB:
				if is_valid_room_position():
					selection_mode = SELECTION_MODE_DEFAULT
				else:
					selected_room.position = $Cursor.position
					
			else:
				selected_room.modulate = Color(1.2, 1.2, 1.2, 1)

		
	if $Camera2D.position.y > -3524.0:
		$Camera2D.position.y = -3524.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		$Camera2D.position.y -= camera_speed * 0.1
	elif event.is_action_pressed("scroll_down"):
		$Camera2D.position.y += camera_speed * 0.1
