# Enemy_Spawner_Box.gd
@tool
class_name EnemySpawnerBox
extends Node2D


var homingTarget: PlayerCharacter
@onready var spawnPosBox: Sprite2D = $spawnPos

var is_active: bool = false
var time: float = 0.0
var curve_progress: float = 0.0
var curve_cur_value: float

var enemy_spawnPos: Vector2


@export var init_param: SpawnParam:
	set (value):
		_load_from_param(value)
		notify_property_list_changed()

@export_enum("Miteo", "Virus") var enemy_name: String
@export_range(1,120, 1) var amount: int = 10
@export_range(0.1, 3.0, 0.01) var spawn_interval: float = 0.2

@export_enum("curve","spin") var param_type : String = "curve":
	set (value):
		param_type = value
		notify_property_list_changed()
	
enum spawn_paramTypes{
	curve,
	spin
}

#region curve parameters
@export var curve_UpDown: bool = true
@export var curve_RightLeft: bool = false

@export var cur_curve : Curve

## set to 1 in order to start the Curve at the end.
@export_range(0.0,1.0, 0.1) var curve_init_time: float = 0.0

@export var curve_type : GlobalTypes.curve_types = GlobalTypes.curve_types.ping_pong
@export var curve_flip : bool = false

@export_range(0.0, 1100.0, 1.0) var curve_waveLength: float = 512.0 

## lower value means faster, default amount is 2.0
@export_range(0.1, 5.0, 0.1) var curve_dur: float = 2.0

#endregion

#region spin parameters
## is also the radius of the circle
@export var spin_initPos : Vector2
@export_enum("clockwise:1","counter clockwise:-1") var spin_dir: int
@export_range(0.1, 400.0, 0.1) var spin_speed: float
#endregion


@export_enum("none","freeze","seek","randomize","follow_spin") var mov_override_name: String = "none"

@export_range(0.0,12.0,0.1) var mov_override_dur: float = 1.0

func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("curve_") and param_type != "curve":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name.begins_with("spin_") and param_type != "spin":
		property.usage = PROPERTY_USAGE_NO_EDITOR

signal get_enemy_data(Node, enemy_name, mov_override: Callable)

var cur_enemy_data: EnemyScaledData
var slide_speed: float = 0.0
var gameStart: bool = false

func activate_spawner():
	global_position.x += 333.0
	is_active = true
	
func deactivate_spawner():
	is_active = false
	set_process(false)
	set_physics_process(false)
	
func _load_from_param(p: SpawnParam) -> void:
	enemy_name     = p.enemy_name
	amount         = p.amount
	spawn_interval = p.spawn_interval
	param_type     = p.param_type

	# Curve params
	curve_init_time  = p.curve_init_time
	curve_type       = p.curve_type
	curve_flip       = p.curve_flip
	curve_waveLength = p.curve_waveLength
	curve_dur        = p.curve_dur
	curve_UpDown     = p.curve_UpDown
	curve_RightLeft  = p.curve_RightLeft

	# Spin params
	spin_initPos = p.spin_initPos
	spin_dir     = p.spin_dir
	spin_speed   = p.spin_speed

	# Override params
	mov_override_name     = p.mov_override
	mov_override_dur = p.mov_override_dur
	

func _ready():
	await get_tree().process_frame
	spawnPosBox.visible = false

var spawn_cooldown: float = 0.0

func _process(delta):
	if gameStart and not is_active:
		global_position += Vector2.LEFT * slide_speed * delta
	if not is_active or cur_enemy_data == null:
		return
	if param_type == "curve":
		time += delta
		if curve_type == GlobalTypes.curve_types.fmod:
			curve_progress = fmod(time,curve_dur) / curve_dur
		elif curve_type == GlobalTypes.curve_types.ping_pong:
			curve_progress = pingpong(time,curve_dur) / curve_dur
		curve_cur_value = cur_curve.sample(curve_progress)
		if curve_flip:
			curve_cur_value = 1 - curve_cur_value 
		
		if curve_UpDown == true:
			spawnPosBox.position.y = lerp(-curve_waveLength, curve_waveLength, curve_cur_value)
		if curve_RightLeft == true:
			spawnPosBox.position.x = lerp(-curve_waveLength, curve_waveLength, curve_cur_value)
		enemy_spawnPos = spawnPosBox.global_position
	spawn_cooldown += delta
	if spawn_cooldown > spawn_interval and amount > 0:
		spawn_cooldown = 0
		amount -= 1
		EnemyPool.put_enemy_toGame(cur_enemy_data,enemy_spawnPos)
		if amount <= 0:
			deactivate_spawner()
	

func _on_visible_on_screen_notifier_2d_screen_entered():
	var _mov_override: Callable = Callable()
	
	match mov_override_name:
		"randomize":
			_mov_override = func(en : Enemy, delta):
				en.override_CustomValue += delta
				if en.override_CustomValue > 0.35:
					en.override_CustomValue = 0
					en.move_dir = Vector2(randf_range(-1,1),randf_range(-1,1))
				
		"seek":
			_mov_override = func(en : Enemy, _delta):
				en.move_dir = en.global_position.direction_to(homingTarget.global_position)
	
	#if mov_override_name == "seek":
		
			

	get_enemy_data.emit(self,enemy_name, _mov_override, mov_override_dur)
