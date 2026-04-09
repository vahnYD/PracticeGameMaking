class_name Cam
extends Camera2D

@export var shake_duration: float = 0.3
@export var shake_strength: float = 8.0

var _shake_timer: float = 0.0
var Player: PlayerCharacter


func shake(_value: float):
	_shake_timer = shake_duration
	if _value > 4.0:
		shake_strength = _value * 1.7
	else:
		shake_strength = 7.0

func load_player(_Player: PlayerCharacter):
	Player = _Player
	if Player:
		Player.hurt.connect(shake)
		

func _process(delta):
	if _shake_timer > 0:
		
		_shake_timer -= delta
		var strength : float = shake_strength * (_shake_timer / shake_duration) # fades out
		offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	else:
		offset = Vector2.ZERO
