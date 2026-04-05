extends Node

var screensize: Vector2
func _ready():
	screensize = get_viewport().get_visible_rect().size
