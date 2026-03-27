
class_name theBullet
extends Area2D

@export var speed: float= 800

func _process(delta):
	position.x += speed * delta


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
	
