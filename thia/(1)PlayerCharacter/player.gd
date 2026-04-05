#player.gd
class_name PlayerCharacter
extends Area2D

func _ready():
	z_index = ZIndex_constants.PLAYER
