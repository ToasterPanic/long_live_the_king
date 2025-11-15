extends CharacterBody2D

var direction = 1

var clock = 0

var speed = 128
var health = 1
var damage_vulnerability = "none"
@onready var game = get_parent().get_parent()

func set_vulnerability(vuln: String):
	damage_vulnerability = vuln
	if vuln == "none":
		$Vulnerability.visible = false
	else:
		$Vulnerability.visible = true
		$Vulnerability.texture = load("res://textures/particles/"+ vuln +"_particle.png")

func _ready() -> void:
	$AboveCheck.position.x *= direction
	set_vulnerability(damage_vulnerability)

func _process(delta: float) -> void:
	clock += delta
	
	if health <= 0:
		queue_free() 
		
	$Sprite2D.rotation_degrees = sin(clock * 16) * 16
	$Sprite2D.position.y = sin(clock * 32) * 4
	
	var above = false
	
	for n in $AboveCheck.get_overlapping_areas():
		if n.get_parent().get_parent().get_name() == "Rooms":
			above = true
		
	if above:
		velocity.y = speed * -1
		velocity.x = 0
	else:
		velocity.x = speed * direction
		
		for n in $InsideCheck.get_overlapping_areas():
			if (n.get_name() == "Area") and (n.get_parent().get_name() == "King"):
				game.gold -= 2
				queue_free()
	
	move_and_slide()
