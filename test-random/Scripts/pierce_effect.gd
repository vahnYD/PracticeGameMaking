extends Sprite2D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(queue_free)
	pass
