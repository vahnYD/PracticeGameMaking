extends Area2D

@export var speed: float = 1900.0  # Matches player export
@export var delay_on_hit: float = 0.05
@export var baseDmg: float = 2

func _physics_process(delta):
	# Move RIGHT (side-scroller style)
	position += Vector2.RIGHT * speed * delta
	
	# Auto-destroy off-screen
	if position.x > get_viewport_rect().size.x:
		queue_free()

# Optional: Hit detection (connect to signals in editor)
#func _on_body_entered(body):
#	if body.is_in_group("enemy"):  # Add enemies to "enemies" group
#		body.queue_free()  # Destroy enemy
#		queue_free()  # Destroy bullet
#	 Or damage system: body.take_damage(1)

func _on_area_entered(area):
	 
	if area.is_in_group("enemy"):  # Add enemies to "enemies" group
		  # Destroy enemy
		#area.HP -= randf() * 20
		area.tookDmg = baseDmg
		await get_tree().create_timer(delay_on_hit).timeout
		queue_free()  # Destroy bullet
	# Or damage system: body.take_damage(1)
