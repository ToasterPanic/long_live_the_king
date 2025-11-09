extends TextureButton


var charm = "gold"
var cost = 5
var game = null
var bought = false

var hovered = false

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false

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
		
		bought = true
		cost = INF
	else:
		$Error.play()
