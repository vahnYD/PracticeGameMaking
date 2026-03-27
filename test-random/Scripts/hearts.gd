
extends Area2D
var tween: Tween
var tween_values = [0, 10]
var speed: float = 32
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= speed * delta

func _ready():	
	tween = get_tree().create_tween()
	glowing()
	
	
func glowing():
	
	tween.tween_property(self,"modulate", Color.DARK_RED, 2)
	tween.tween_property(self,"modulate", Color.DEEP_PINK, 2)
	tween.tween_property(self,"modulate", Color.WHITE, 1.5)
	tween.parallel().tween_property(self,"scale",Vector2(0.5,0.5) ,1.5)
	tween.parallel().tween_property(self,"modulate", Color.TRANSPARENT, 1.5)
	tween.tween_callback(queue_free)


func _on_timer_timeout():
	speed += 8
	pass # Replace with function body.
