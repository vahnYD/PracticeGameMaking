extends Label

@export var Player: CharacterBody2D

func _ready():
	if not Player == null:
		Player.HpChanged.connect(_onHpChanged)

func _onHpChanged(newHP: float):
	print(newHP)
	text = "HP : " + str(newHP)
