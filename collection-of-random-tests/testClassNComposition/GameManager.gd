extends Node2D
class_name GameManager

signal SummonNow

@export var SpawnTimer: Timer

func _ready():
	if not $SpawnTimer == null:
		SpawnTimer = $SpawnTimer
		




func _on_spawn_timer_timeout():
	emit_signal("SummonNow")
