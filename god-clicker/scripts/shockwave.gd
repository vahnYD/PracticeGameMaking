class_name Shockwave
extends Area2D

@export var damage: float = 50.0


func _ready():
	# Detect enemies and deal damage
	#area_entered.connect(_on_area_entered)
	
	# Shockwave lasts for 0.25 seconds before disappearing
	await get_tree().create_timer(0.25).timeout
	call_deferred("queue_free")

func _on_area_entered(area):
	# Check if the area is our HitboxComponent
	if area is HitboxComponent:
		area.take_damage(damage)
