class_name global_scripts
extends Node

var current_game_state : String

var count : int
var max_ScreenSize : Vector2

var playscreen_Size : Vector2

func _ready():
	playscreen_Size = get_viewport().size
	max_ScreenSize = get_viewport().get_visible_rect().size
