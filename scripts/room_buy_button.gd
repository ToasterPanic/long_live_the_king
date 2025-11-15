extends TextureButton


var wallpaper = "plain"
var room = "spikes"
var cost = 5
var game = null
var bought = false

var hovered = false

var tooltip_scene = preload("res://scenes/tooltip.tscn")
var tooltip = null

func _on_mouse_entered() -> void:
	hovered = true
	
	tooltip = tooltip_scene.instantiate()
	#tooltip.global_position = get_viewport().get_mouse_position()
	tooltip.position = get_viewport().get_mouse_position()#Vector2(0, 0)
	
	tooltip.get_node("Label").text = """[font_size=28]%s %s[/font_size]
%-1d base damage per second
	
%s""" % [
		global.wallpaper_stats[wallpaper].name,
		global.room_stats[room].name,
		floori(global.room_stats[room].damage),
		global.wallpaper_stats[wallpaper].stat_description
	]
	
	get_parent().get_parent().get_parent().get_parent().get_parent().add_child(tooltip)

func _on_mouse_exited() -> void:
	hovered = false
	if tooltip:
		tooltip.queue_free()

func _ready() -> void:
	$Label.text = " $" + str(cost)

	texture_normal = load("res://textures/wallpapers/" + wallpaper + ".png")
	$Room.texture = load("res://textures/rooms/" + room + ".png")
	
	cost = global.room_stats[room].shop_cost + global.wallpaper_stats[wallpaper].shop_cost
	
	$Label.text = " $" + str(cost)
	
	var found = false
	
	game = get_parent()
	
	while not found:
		if game.get_name() == "Game":
			found = true
			break
			
		game = game.get_parent()

func _process(delta: float) -> void:
	if tooltip:
		tooltip.position = get_viewport().get_mouse_position()
		tooltip.position.y -= tooltip.size.y
	
	if bought:
		modulate = Color(0.2, 0.2, 0.2)
		$Room.visible = false
		$Label.text = " SOLD!"
	elif hovered:
		modulate = Color(1.25, 1.25, 1.25)
	else:
		modulate = Color(1, 1, 1)

func _on_button_down() -> void:
	if game.gold >= cost:
		game.gold -= cost
		
		$Buy.play()
		
		var new_room = game.new_room()
		#new_room.wallpaper = wallpaper
		new_room.room = room
		new_room.wallpaper = wallpaper
		new_room.initialize()
		new_room.position = Vector2(3230.0, -3855)
		new_room.modulate = Color(0, 1, 0, 1)
		
		game.selected_room = new_room
		game.selection_mode = game.SELECTION_MODE_GRAB
		game.deselect_cooldown = 0.1
		#game.tower_invalid = true
		#g#ame.failures.push_front("RoomBought")
		
		bought = true
		cost = INF
	else:
		$Error.play()
