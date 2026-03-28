extends TextureProgressBar
var screen_size: Vector2

func _ready():
	# Get the size of the visible viewport
	screen_size = get_viewport_rect().size
	global_position = get_parent().global_position

func _physics_process(_delta):
	# Clamp the object's position within screen bounds
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	
