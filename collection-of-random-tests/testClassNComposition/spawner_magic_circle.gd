extends Area2D

@onready var theSummonAnimation: Timer = $SummonAnimation
@onready var Sprite: Sprite2D = $Sprite2D
@export var Minion: PackedScene
const Game = "res://ClassTest.tscn"

func _ready():
	if not Game == null:
		_on_summon_received()
	pass
		
func _on_summon_received():
	Sprite.visible = true
	print("Summon")
		
#await get_tree().create_timer(1).timeout
