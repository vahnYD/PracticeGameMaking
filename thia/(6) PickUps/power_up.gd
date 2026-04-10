class_name Power_Up
extends Area2D

@export var UpValue: int = 1

@onready var sprite : Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var despawn_timer : Timer = $DespawnTimer

var tween: Tween

func start_pulse(target: Node2D, scale_amount: float = 1.1, speed: float = 0.88):
	tween = create_tween()
	tween.set_loops()                          # loop forever
	tween.set_trans(Tween.TRANS_SINE)          # smooth in/out
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "scale", Vector2.ONE * scale_amount, speed)
	tween.tween_property(target, "scale", Vector2.ONE,                speed)

func _ready():
	z_index = ZIndex_constants.PICKUPS
	start_pulse(self)
	
var move_speed: float = 160.0
func _process(delta):
	global_position += Vector2.LEFT * move_speed * delta


func fade():
	tween.kill()
	var _tween : Tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.1, 1.2)
	await _tween.finished
	#_tween.kill()
	queue_free()
	

func _on_timer_timeout():
	fade()
