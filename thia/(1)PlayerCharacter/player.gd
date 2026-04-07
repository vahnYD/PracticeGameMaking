#player.gd
class_name PlayerCharacter
extends Area2D

var playscreensize_MAX: Vector2
const playscreen_offset : float = 128.0


var move_speed: float = 800.0
var accel_speed: float = 5275.0
var move_friction: float  = 6000.0
var cur_velocity: Vector2 = Vector2.ZERO

func _ready():
	z_index = ZIndex_constants.PLAYER
	await get_tree().process_frame
	playscreensize_MAX = GameManager.viewport_size
	playscreensize_MAX.x -= 256.0
	playscreensize_MAX.y -= playscreen_offset

func _process(delta):
	var input_dir = Input.get_vector("go_LEFT", "go_RIGHT", "go_UP", "go_DOWN")
	if input_dir != Vector2.ZERO:
		cur_velocity = cur_velocity.move_toward(input_dir * move_speed, accel_speed * delta)
	else:
		cur_velocity = cur_velocity.move_toward(Vector2.ZERO, move_friction * delta)
		
	global_position += cur_velocity * delta
	global_position = global_position.clamp(Vector2(playscreen_offset,playscreen_offset), playscreensize_MAX)
	
func _on_area_entered(area):
	if area is Enemy:
		# apply damage here
		area.deactivate()
