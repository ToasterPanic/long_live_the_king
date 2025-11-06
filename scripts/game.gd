extends Node2D

var camera_speed = 512

func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_up"):
		$Camera2D.position.y -= delta * camera_speed
	if Input.is_action_pressed("camera_down"):
		$Camera2D.position.y += delta * camera_speed
		
	if $Camera2D.position.y > -3524.0:
		$Camera2D.position.y = -3524.0
		
	$Cursor.position.x = (roundi(get_global_mouse_position().x + 64) / 128) * 128 
	$Cursor.position.y = (roundi(get_global_mouse_position().y - 64) / 128) * 128


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		$Camera2D.position.y -= camera_speed * 0.1
	elif event.is_action_pressed("scroll_down"):
		$Camera2D.position.y += camera_speed * 0.1
