extends Sprite2D

var isCopy: bool = false

func activate():
	show()
	modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	hide()
	if isCopy:
		queue_free()
	
func _ready():
	hide()
