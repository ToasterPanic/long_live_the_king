extends Node2D

var camera_speed = 512
var gold = 6
var next_spawn = 1
var wave = 1
var current_wave_spawned = 0
var active_wave = false
var tower_invalid = false
var failures = []
var clock = 0

#- Tower must be in the center
#- Rooms must be supported below
#- Rooms cannot be inside each other
#- Rooms cannot be underground

const SELECTION_MODE_DEFAULT = 0
const SELECTION_MODE_GRAB = 1

var selected_room = null 
var selection_mode = SELECTION_MODE_DEFAULT
var time_selection_clicked = 0

var room_buy_button_scene = preload("res://scenes/room_buy_button.tscn")
var room_scene = preload("res://scenes/room.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

# Specifically for the add_gold console command. Do not use
func add_gold(amount: int) -> void:
	gold += amount
	LimboConsole.info("Added " + str(amount) + " gold to player balance!")

# Creates a room, puts it in the right place.
func new_room():
	var room = room_scene.instantiate()
	
	$Rooms.add_child(room)
	
	return room

func set_selected_room(new):
	if selected_room:
		if selected_room.invalid:
			selected_room.modulate = Color(1, 0, 0, 1)
		else:
			selected_room.modulate = Color(1, 1, 1, 1)
	
	selected_room = new
	new.modulate = Color(1.2, 1.2, 1.2, 1)
	
# Checks if the currently-selected room (at the cursor) is valid.
func is_valid_room_position(room):
	LimboConsole.info(room.get_name())
	
	for n in room.get_node("InsideCheck").get_overlapping_areas():
		if n.get_name() == "Area":
			if n.get_parent() != room:
				LimboConsole.info("Failed InsideCheck")
				return false
		if n.get_name() == "Blocker":
			LimboConsole.info("Failed Blocker")
			return false
		if n.get_name() == "Blocker2":
			LimboConsole.info("Failed Blocker2")
			return false
			
	for n in room.get_node("BelowCheck").get_overlapping_bodies():
		if n.get_name() == "TileMapLayer":
			LimboConsole.info("Passed TileMapLayerCheck")
			return true
			
	for n in room.get_node("BelowCheck").get_overlapping_areas():
		if n.get_name() == "Area":
			LimboConsole.info("Passed Area")
			return true
			
	LimboConsole.info("Failed All")
			
	return false

func scramble_shop():
	for n in $UI/Control/Shop/Scroll/HBox.get_children(): n.queue_free()
	
	# The loot tables for rooms and their wallpapers are recalculated every round for reasons
	var room_randomized_table = []
	var wallpaper_randomized_table = []
	
	for n in global.room_stats.keys():
		var room = global.room_stats[n]
		
		# Ignore rooms that are too early to appear
		if room.has("starting_wave") and (room.starting_wave > wave):
				continue
		
		# Add room to loot table a certain amount of times
		var i = 0
		while i < room.shop_rarity:
			room_randomized_table.push_front(n)
			
			i += 1
			
	for n in global.wallpaper_stats.keys():
		var wallpaper = global.wallpaper_stats[n]
		
		# Ignore rooms that are too early to appear
		if wallpaper.has("starting_wave") and (wallpaper.starting_wave < wave):
			continue
		
		# Add room to loot table a certain amount of times
		var i = 0
		while i < wallpaper.shop_rarity:
			wallpaper_randomized_table.push_front(n)
			
			i += 1
	
	var i = 0
	while i < 4:
		var room_buy_button = room_buy_button_scene.instantiate()
		
		room_buy_button.room = room_randomized_table[randi_range(0, room_randomized_table.size() - 1)]
		room_buy_button.wallpaper = wallpaper_randomized_table[randi_range(0, wallpaper_randomized_table.size() - 1)]
		
		$UI/Control/Shop/Scroll/HBox.add_child(room_buy_button)
		
		i += 1

func _ready() -> void:
	LimboConsole.register_command(add_gold)
	
	scramble_shop()

func _process(delta: float) -> void:
	clock += delta
	
	# Make sure the enemy spawns are right off the screen (todo: minimum size for build limit horiz...)
	$SpawnLeft.position.x = $Camera2D.position.x - (DisplayServer.window_get_size().x / 2) - 64
	$SpawnRight.position.x = $Camera2D.position.x+ (DisplayServer.window_get_size().x / 2) + 64
	
	if Input.is_action_pressed("camera_up"):
		$Camera2D.position.y -= delta * camera_speed
	if Input.is_action_pressed("camera_down"):
		$Camera2D.position.y += delta * camera_speed
		
	# Moves the square cursor to a point on the grid
	$Cursor.position.x = (roundi(get_global_mouse_position().x + 64) / 128) * 128 
	$Cursor.position.y = (roundi(get_global_mouse_position().y - 64) / 128) * 128
	
	$UI/Control/Gold.text = str(gold) + " GOLD"
	
	if Input.is_action_just_pressed("select"):
		for n in $Rooms.get_children():
			if n.hovered:
				set_selected_room(n)
	elif Input.is_action_pressed("select"):
		if selection_mode == SELECTION_MODE_GRAB:
			selected_room.get_node("Room").rotation_degrees = sin(clock * 12) * 15
			selected_room.get_node("Wallpaper").rotation = selected_room.get_node("Room").rotation
			
			if selected_room.get_node("Wallpaper").global_position != get_global_mouse_position():
				selected_room.position = $Cursor.position
				
				selected_room.get_node("Wallpaper").global_position = get_global_mouse_position()
				selected_room.get_node("Room").global_position = get_global_mouse_position()
				
				selected_room.invalid = !is_valid_room_position(selected_room)
				
				# Since Area2Ds only update on physics steps, we must wait
				await get_tree().physics_frame
				await get_tree().physics_frame
				
				tower_invalid = false
				
				for n in $Rooms.get_children():
					n.invalid = !is_valid_room_position(n)
					if n.invalid:
						n.modulate = Color(1, 0.4, 0.4, 1)
						tower_invalid = true
					else:
						n.modulate = Color(1.4, 1.4, 1.4, 1)
				
				
		if selected_room and selected_room.hovered and not active_wave:
			time_selection_clicked += delta
			selection_mode = SELECTION_MODE_GRAB
	else:
		time_selection_clicked = 0
		if selected_room:
			selected_room.get_node("Wallpaper").position = Vector2()
			selected_room.get_node("Wallpaper").rotation = 0
			
			selected_room.get_node("Room").position = Vector2()
			selected_room.get_node("Room").rotation = 0
			
			if selection_mode == SELECTION_MODE_GRAB:
				selection_mode = SELECTION_MODE_DEFAULT
			else:
				if selected_room.invalid:
					selected_room.modulate = Color(1, 0.2, 0.2, 1)
				else:
					selected_room.modulate = Color(1.2, 1.2, 1.2, 1)

		
	if $Camera2D.position.y > -3524.0:
		$Camera2D.position.y = -3524.0
		
	if tower_invalid:
		$UI/Control/StartWave/Label.text = "TOWER INVALID"
		$UI/Control/StartWave.modulate = Color(.5, .5, .5)
	elif active_wave:
		$UI/Control/StartWave/Label.text = "WAVE IN PROGRESS"
		$UI/Control/StartWave.modulate = Color(.5, .5, .5)
	else:
		$UI/Control/StartWave/Label.text = "START WAVE"
		$UI/Control/StartWave.modulate = Color(1, 1, 1)
		
	next_spawn -= delta 
	
	if active_wave:
		if current_wave_spawned > 5:
			if $Enemies.get_children().size() == 0:
				active_wave = false
				wave += 1
				
				current_wave_spawned = 0
				
				gold += 5 + floori(wave / 3)
				
				$UI/Control/Shop.visible = true
				
				scramble_shop()
				
			return
			
		$UI/Control/Shop.visible = false
		
		if next_spawn <= 0:
			next_spawn = max(1 - (0.0666 * wave), 0.2)
			current_wave_spawned += 1
			
			var enemy = enemy_scene.instantiate()
			$Enemies.add_child(enemy)
			
			# No idea how to square a float. Don't feel like figuring it out
			var unsquared = (((wave - 1) + 4.5) / 4.5)
			var multiplier = unsquared * unsquared
			
			enemy.health = 1 * multiplier
			
			enemy.position = $SpawnLeft.position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		$Camera2D.position.y -= camera_speed * 0.1
	elif event.is_action_pressed("scroll_down"):
		$Camera2D.position.y += camera_speed * 0.1


func _on_start_wave_pressed() -> void:
	if (not active_wave) and (not tower_invalid):
		active_wave = true
