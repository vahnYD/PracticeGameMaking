extends Sprite2D

var slide_speed: float

func _process(delta):
	global_position += Vector2.LEFT * slide_speed * delta
