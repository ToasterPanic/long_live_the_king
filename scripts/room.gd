extends Node2D


var room = "king"
var hovered = false

func _on_area_mouse_entered() -> void:
	hovered = true

func _on_area_mouse_exited() -> void:
	hovered = false

func initialize() -> void:
	$Room.texture = load("res://textures/rooms/" + room + ".png")

func _process(delta: float) -> void:
	pass
