extends Node2D


var room = "king"
var wallpaper = "plain"
var hovered = false
var selected = false
var invalid = false
var room_stats = null

func _on_area_mouse_entered() -> void:
	hovered = true

func _on_area_mouse_exited() -> void:
	hovered = false

func initialize() -> void:
	$Room.texture = load("res://textures/rooms/" + room + ".png")
	$Wallpaper.texture = load("res://textures/wallpapers/" + wallpaper + ".png")
	
	room_stats = global.room_stats[room]
	
	

func _process(delta: float) -> void:
	if !room_stats:
		return
	
	for n in $Area.get_overlapping_bodies():
		if n.get_parent().get_name() == "Enemies":
			var damage_type = room_stats.damage_type
			var damage = room_stats.damage
			
			if wallpaper == "grimy":
				damage *= 1.5
				damage_type = "blunt"
			elif wallpaper == "firey":
				damage *= 1.5
				damage_type = "fire" 
			elif wallpaper == "supernatural":
				damage *= 1.5
				damage_type = "magic"
			
			n.health -= delta * damage
