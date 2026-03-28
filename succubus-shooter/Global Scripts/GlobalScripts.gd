extends Node
class_name global_script

var current_game_state : String

var count : int
var max_ScreenSize : Vector2

var playscreen_Size : Vector2

func _ready():
	#render_resolution = get_viewport().size
	#print(render_resolution)
	#playscreen_Size = DisplayServer.window_get_size()
	
	playscreen_Size = get_viewport().size
	max_ScreenSize = get_viewport().get_visible_rect().size
