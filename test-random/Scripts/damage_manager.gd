extends CanvasLayer

@export var damageNumberScene: PackedScene = preload("res://scenes/DamageNumber.tscn")

# Called when the node enters the scene tree for the first time.

func spawnDamage(
	worldpos: Vector2,
	damage: int,
	color: Color = Color.BLACK,
	offset: Vector2 = Vector2.ZERO
) -> void:
	var instance := damageNumberScene.instantiate() as Control
	add_child(instance)
	
	
	#var Camera: Camera2D = get_viewport().get_camera_2d()
	#var screen_pos: Vector2
	#if Camera:
		#screen_pos = Camera.get_screen_transform() * worldpos
		#
	#else:
		#screen_pos = worldpos # Fallback for editor/preview
		
		
	instance.position = worldpos + offset
	instance.z_index = 5
	instance.show_damage(damage, color)
	
