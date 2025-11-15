extends TextureButton


var charm = "gold"
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
	
	tooltip.get_node("Label").text = """[font_size=28]%s[/font_size]

%s""" % [
		global.charm_stats[charm].name,
		global.charm_stats[charm].stat_description
	]
	
	get_parent().get_parent().get_parent().get_parent().get_parent().add_child(tooltip)

func _on_mouse_exited() -> void:
	hovered = false
	
	if tooltip:
		tooltip.queue_free()

func _ready() -> void:
	$Label.text = " $" + str(cost)

	texture_normal = load("res://textures/charms/" + charm + ".png")
	
	cost = global.charm_stats[charm].shop_cost 
	
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
		$Label.text = " SOLD!"
	elif hovered:
		modulate = Color(1.25, 1.25, 1.25)
	else:
		modulate = Color(1, 1, 1)

func _on_button_down() -> void:
	if game.gold >= cost:
		game.gold -= cost
		
		$Buy.play()
		
		game.charms.push_front(charm)
		
		bought = true
		cost = INF
	else:
		$Error.play()
