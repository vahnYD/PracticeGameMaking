extends Control
# Called when the node enters the scene tree for the first time.


@export var float_distance: float = 110.0
@export var duration: float = 0.55
@export var start_scale: Vector2 = Vector2(1.5, 1.5)

@onready var label: Label = $Label


func show_damage(value: int, color: Color) -> void:
	label.text = str(value)
	label.modulate = color
	modulate.a = 1.0
	scale = start_scale
	
	#await get_tree().create_timer(0.25).timeout
	#queue_free()
	
	#var tween := create_tween()
	
	var tween = get_tree().create_tween()
	
	#tween.tween_property(self, "position", Vector2.ZERO * 0.3 + Vector2(global_position.x, global_position.y - float_distance), duration)
	
	tween.tween_property(self,"position",Vector2(position.x, position.y - 12), duration - 0.1)
	tween.tween_property(self, "modulate", Color.BLUE, duration * 0.1)
	
	tween.tween_callback(queue_free)
