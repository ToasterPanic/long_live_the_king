extends Node2D

var switch_screen = "home"

func _ready() -> void:
	$UI/Control/Settings/BackToHome.connect("pressed", _on_back_to_home_pressed)

func _process(delta: float) -> void:
	if switch_screen == "home":
		$Camera2D.position.y = 0
		$UI/Control/FadeToBlack.color.a -= delta
		$UI/Control/VBox.modulate.a += delta * 2
		
		if $UI/Control/FadeToBlack.color.a < 0:
			$UI/Control/FadeToBlack.color.a = 0
			
		if $UI/Control/VBox.modulate.a > 1:
			$UI/Control/VBox.modulate.a = 1
			
		$UI/Control.position.y = $Camera2D.position.y
		
		$UI/Control/Settings.visible = false
		$UI/Control/CreditsExtras.visible = false
	elif switch_screen == "new_game":
		$Camera2D.position.y = 2000
		
		$UI/Control/FadeToBlack.color.a += delta * 2
		
		if $UI/Control/FadeToBlack.color.a > 1.5:
			get_tree().change_scene_to_file("res://scenes/game.tscn")
			
		$UI/Control.position.y = $Camera2D.position.y
		$UI/Control/FadeToBlack.position.y = -$Camera2D.position.y
	elif switch_screen == "settings":
		$Camera2D.position.y = 2000
		
		$UI/Control/VBox.modulate.a -= delta * 2
		
		$UI/Control/FadeToBlack.color.a += delta * 2
		$UI/Control/Settings.visible = true
		
		if $UI/Control/FadeToBlack.color.a > 1:
			$UI/Control/FadeToBlack.color.a = 1
			
		if $UI/Control/VBox.modulate.a < 0:
			$UI/Control/VBox.modulate.a = 0
			
		$UI/Control.position.y = 0
		$UI/Control/FadeToBlack.position.y = 0
	elif switch_screen == "credits_extras":
		$Camera2D.position.y = 2000
		
		$UI/Control/VBox.modulate.a -= delta * 2
		
		$UI/Control/FadeToBlack.color.a += delta * 2
		$UI/Control/CreditsExtras.visible = true
		
		if $UI/Control/FadeToBlack.color.a > 1:
			$UI/Control/FadeToBlack.color.a = 1
			
		if $UI/Control/VBox.modulate.a < 0:
			$UI/Control/VBox.modulate.a = 0
			
		$UI/Control.position.y = 0
		$UI/Control/FadeToBlack.position.y = 0
	


func _on_new_game_pressed() -> void:
	switch_screen = "new_game"


func _on_settings_pressed() -> void:
	switch_screen = "settings"


func _on_back_to_home_pressed() -> void:
	switch_screen = "home"


func _on_credits_extras_pressed() -> void:
	switch_screen = "credits_extras"
