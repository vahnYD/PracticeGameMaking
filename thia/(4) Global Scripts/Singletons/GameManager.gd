extends Node

var viewport_size: Vector2

func _ready():
	viewport_size = get_viewport().get_visible_rect().size
