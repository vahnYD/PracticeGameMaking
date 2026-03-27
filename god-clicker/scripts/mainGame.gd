extends Node2D

@export var shockwave_scene: PackedScene # Assign your Shockwave.tscn here
@export var LevelDifficulty: int
@onready var cooldownTimer: Timer = $AttackTimer


var canAttack: bool = true

func _input(event):
	# Check for Left Mouse Button click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and canAttack:
		summon_shockwave(get_global_mouse_position())

func summon_shockwave(pos: Vector2):
	var shockwave = shockwave_scene.instantiate()
	shockwave.global_position = pos
	add_child(shockwave)
	canAttack = false
	cooldownTimer.start()


func _on_timer_timeout():
	canAttack = true
	
