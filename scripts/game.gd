extends Node2D

var camera_speed = 512
var gold = 9
var next_spawn = 1
var wave = 1
var current_wave_spawned = 0
var active_wave = false
var tower_invalid = false
var failures = []
var clock = 0

var charms = []

var deselect_cooldown = 0

var mouse_busy = false

const SELECTION_MODE_DEFAULT = 0
const SELECTION_MODE_GRAB = 1

var selected_room = null 
var selection_mode = SELECTION_MODE_DEFAULT
var time_selection_clicked = 0

var room_buy_button_scene = preload("res://scenes/room_buy_button.tscn")
var charm_buy_button_scene = preload("res://scenes/charm_buy_button.tscn")
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

# This was made at a point where room selection worked differently. This is mostly
# unneccesary but I've kept it in because I am too lazy
func set_selected_room(new):
	if selected_room:
		if selected_room.invalid:
			selected_room.modulate = Color(1, 0, 0, 1)
		else:
			selected_room.modulate = Color(1, 1, 1, 1)
	
	selected_room = new
	new.modulate = Color(1.2, 1.2, 1.2, 1)
	
# Checks if the currently-selected room (at the cursor) is valid.
func is_valid_room_position(room, info = false):
	LimboConsole.info(room.get_name())
	
	if room.get_name() != "King":
		if room.position.y < $Rooms/King.position.y:
			LimboConsole.info("Failed KingTop")
			if info:
				return "KingTop"
			else:
				return false
	
	for n in room.get_node("InsideCheck").get_overlapping_areas():
		if n.get_name() == "Area":
			if n.get_parent() != room:
				LimboConsole.info("Failed InsideCheck")
				if info:
					return "InsideCheck"
				else:
					return false
		if n.get_name() == "Blocker":
			LimboConsole.info("Failed Blocker")
			if info:
				return "Blocker"
			else:
				return false
		if n.get_name() == "Blocker2":
			LimboConsole.info("Failed Blocker2")
			if info:
				return "Blocker"
			else:
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
			
	if info:
		return "NeedsSupport"
	else:
		return false

func scramble_shop():
	for n in $UI/Control/Shop/Scroll/HBox/Rooms.get_children(): n.queue_free()
	for n in $UI/Control/Shop/Scroll/HBox/Charms.get_children(): n.queue_free()
	
	# The loot tables are recalculated every round
	# This is so we can filter out items that are too early in
	var room_randomized_table = []
	var wallpaper_randomized_table = []
	var charm_randomized_table = []
	
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
			
	for n in global.charm_stats.keys():
		var charm = global.charm_stats[n]
		
		# Ignore charms that are too early to appear
		if charm.has("starting_wave") and (charm.starting_wave < wave):
			continue
		
		# Add room to loot table a certain amount of times
		var i = 0
		while i < charm.shop_rarity:
			charm_randomized_table.push_front(n)
			
			i += 1
	
	var i = 0
	while i < 3:
		var room_buy_button = room_buy_button_scene.instantiate()
		
		room_buy_button.room = room_randomized_table[randi_range(0, room_randomized_table.size() - 1)]
		room_buy_button.wallpaper = wallpaper_randomized_table[randi_range(0, wallpaper_randomized_table.size() - 1)]
		
		$UI/Control/Shop/Scroll/HBox/Rooms.add_child(room_buy_button)
		
		i += 1
		
	i = 0
	if charms.has("carpentry"):
		while i < 2:
			var room_buy_button = room_buy_button_scene.instantiate()
		
			room_buy_button.room = room_randomized_table[randi_range(0, room_randomized_table.size() - 1)]
			room_buy_button.wallpaper = wallpaper_randomized_table[randi_range(0, wallpaper_randomized_table.size() - 1)]
			
			$UI/Control/Shop/Scroll/HBox/Charms.add_child(room_buy_button)
			
			i += 1
	else:
		while i < 2:
			var charm_buy_button = charm_buy_button_scene.instantiate()
			
			charm_buy_button.charm = charm_randomized_table[randi_range(0, charm_randomized_table.size() - 1)]

			$UI/Control/Shop/Scroll/HBox/Charms.add_child(charm_buy_button)
			
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
	
	$UI/Control/InfoPanel/HBox/Gold.text = str(gold) + " GOLD"
	
	if Input.is_action_just_pressed("select"):
		for n in $Rooms.get_children():
			if n.hovered:
				set_selected_room(n)
				$PickUp.play()
	elif Input.is_action_pressed("select"):
		if selection_mode == SELECTION_MODE_GRAB:
			deselect_cooldown -= delta
			
			selected_room.get_node("Room").rotation_degrees = sin(clock * 12) * 15
			selected_room.get_node("Wallpaper").rotation = selected_room.get_node("Room").rotation
			
			if selected_room.get_node("Wallpaper").global_position != get_global_mouse_position():
				
				selected_room.get_node("Wallpaper").global_position = get_global_mouse_position()
				selected_room.get_node("Room").global_position = get_global_mouse_position()
				
				if selected_room.position != $Cursor.position:
					selected_room.position = $Cursor.position
					
					selected_room.get_node("Wallpaper").global_position = get_global_mouse_position()
					selected_room.get_node("Room").global_position = get_global_mouse_position()
					
					selected_room.invalid = !is_valid_room_position(selected_room)
					
					# Since Area2Ds only update on physics steps, we must wait
					await get_tree().physics_frame
					await get_tree().physics_frame
					
					tower_invalid = false
					
					failures = []
					
					for n in $Rooms.get_children():
						var check = is_valid_room_position(n, true)
						n.invalid = typeof(check) != typeof(false)
						
						if n.invalid:
							n.modulate = Color(1, 0.4, 0.4, 1)
							tower_invalid = true
							
							failures.push_front(check)
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
			
			if (selection_mode == SELECTION_MODE_GRAB) and (deselect_cooldown <= 0):
				selection_mode = SELECTION_MODE_DEFAULT
				$PickUp.stop()
				$Place.play()
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
		
		$UI/Control/StartWave/HintText.text = ""
		if failures.has("RoomBought"):
			$UI/Control/StartWave/HintText.text = $UI/Control/StartWave/HintText.text + "- Please move your recently-bought room\n"
		if failures.has("InsideCheck"):
			$UI/Control/StartWave/HintText.text = $UI/Control/StartWave/HintText.text + "- Rooms cannot be inside each other\n"
		if failures.has("NeedsSupport"):
			$UI/Control/StartWave/HintText.text = $UI/Control/StartWave/HintText.text + "- Rooms must be supported and above ground\n"
		if failures.has("Blocker"):
			$UI/Control/StartWave/HintText.text = $UI/Control/StartWave/HintText.text + "- Tower must be in the center\n"
		if failures.has("KingTop"):
			$UI/Control/StartWave/HintText.text = $UI/Control/StartWave/HintText.text + "- The king must be at the top of the tower\n"
	elif active_wave:
		$UI/Control/StartWave/Label.text = "WAVE IN PROGRESS"
		$UI/Control/StartWave.modulate = Color(.5, .5, .5)
	else:
		$UI/Control/StartWave/Label.text = "START WAVE"
		$UI/Control/StartWave.modulate = Color(1, 1, 1)
		$UI/Control/StartWave/HintText.text = ""
		
	next_spawn -= delta 
	
	if gold < 0:
		get_tree().paused = true
		$UI/Control/Pillaged.visible = true 
	
	if active_wave:
		if current_wave_spawned > 5:
			if $Enemies.get_children().size() == 0:
				active_wave = false
				wave += 1
				
				current_wave_spawned = 0
				
				gold += 5 + floori(wave / 3)
				
				for n in charms:
					if n == "gold":
						gold += 2
				
				$UI/Control/Shop.visible = true
				
				scramble_shop()
				
			return
			
		$UI/Control/Shop.visible = false
		
		if next_spawn <= 0:
			next_spawn = max(1 - (0.0666 * wave), 0.2)
			current_wave_spawned += 1
			
			var enemy = enemy_scene.instantiate()
			
			
			if randi_range(0, 1) == 1:
				enemy.direction = 1
				enemy.position = $SpawnLeft.position
			else:
				enemy.direction = -1
				enemy.position = $SpawnRight.position
				
			if wave > 2:
				var items = ["none", "none", "blunt", "fire", "magic"]
				enemy.damage_vulnerability = items[randi_range(0, items.size() - 1)]
			
			# No idea how to square a float. Don't feel like figuring it out
			var unsquared = (((wave - 1) + 1.75) / 1.75)
			var multiplier = unsquared * unsquared
			
			enemy.health = 1 * multiplier
			
			
			
			$Enemies.add_child(enemy)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		$Camera2D.position.y -= camera_speed * 0.1
	elif event.is_action_pressed("scroll_down"):
		$Camera2D.position.y += camera_speed * 0.1


func _on_start_wave_pressed() -> void:
	if (not active_wave) and (not tower_invalid):
		active_wave = true


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_shop_mouse_entered() -> void:
	mouse_busy = true


func _on_shop_mouse_exited() -> void:
	mouse_busy = false
