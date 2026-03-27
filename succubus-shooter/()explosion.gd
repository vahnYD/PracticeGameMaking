extends Sprite2D

var time: float = 0

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.35)
	await tween.finished
	queue_free()
