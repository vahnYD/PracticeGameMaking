# Enemy_Blank.gd
class_name Enemy
extends Area2D

#region enemy basic stats
var enemy_name: String = "unknown"
var HP: float = 10.0
var max_HP: float = 10.0
var ATK: float = 5.0
var DEF: float = 0.0
var move_spd: float = 300.0
var move_type: GlobalTypes.enemy_move_types = GlobalTypes.enemy_move_types.straight
#endregion

#region move override vars
var move_override: Callable
var move_overrideDur: float = 0.0

## whatever needed data for the movement override
var override_CustomValue: float = 0.0
var override_VeerStr: float = 0.0
var move_OverrideDir: Vector2 = Vector2.ZERO
#endregion

#region if move_type is Homing
var homing_cooldown: float = 0.133
var homing_reset: float = 0.133
var homing_dir: Vector2
var homing_strength: float = 0.5
var player_target: PlayerCharacter
#endregion


var move_dir: Vector2 = Vector2.ZERO

@onready var body_pic : AnimatedSprite2D = $bodyPic
@onready var collission: CollisionShape2D = $Collision
@onready var lifetimeTimer: Timer = $lifeTime

var activated: bool = false
var isSpecial: float = 0.0

var move_overrideDurMax : float = 0.0

var onSpawnFunc: Callable = Callable()

signal returnedToPool(Enemy)


func load_data(_enemy_dict : EnemyScaledData):
	
	if _enemy_dict.onSpawnFunc.is_valid():
		onSpawnFunc = _enemy_dict.onSpawnFunc
	else:
		onSpawnFunc = Callable()
	if _enemy_dict.move_Override.is_valid():
		move_override = _enemy_dict.move_Override
	else:
		move_override = Callable()
	move_overrideDur = _enemy_dict.move_overrideDur
	move_overrideDurMax = _enemy_dict.move_overrideDur
	override_VeerStr = _enemy_dict.override_VeerStr
	enemy_name = _enemy_dict.enemy_name
	HP = _enemy_dict.HP
	max_HP = _enemy_dict.HP
	ATK = _enemy_dict.ATK
	DEF = _enemy_dict.DEF
	move_spd = _enemy_dict.move_spd
	move_type = _enemy_dict.move_type
	body_pic.sprite_frames = _enemy_dict.sprite
	collission.shape = _enemy_dict.collision_shape
	if _enemy_dict.is_special > 1.0:
		isSpecial =  _enemy_dict.is_special
		scale = Vector2(_enemy_dict.is_special,_enemy_dict.is_special)
	else:
		isSpecial = 0.0
		scale = Vector2(1,1)
	if move_type == GlobalTypes.enemy_move_types.homing:
		player_target = _enemy_dict.player_target
	
	activate()
	

func _process(delta):
	## move depending movetype
	match move_type:
		GlobalTypes.enemy_move_types.straight:
			basic_movement()
		GlobalTypes.enemy_move_types.homing:
			homing_cooldown -= delta
			if homing_cooldown <= 0 :
				homing_movement()
				homing_cooldown = homing_reset
	if move_overrideDur > 0:
		move_overrideDur -= delta
		if move_override.is_valid():
			move_override.call(self, delta)
	elif move_overrideDur <= 0:
		move_OverrideDir = Vector2.ZERO
	move_dir = (move_dir + move_OverrideDir).normalized()
	global_position += move_dir * move_spd * delta 

	
func basic_movement():
	move_dir = Vector2.LEFT
	
func homing_movement():
	homing_dir = global_position.direction_to(player_target.global_position).normalized()
	move_dir = (Vector2.LEFT + homing_dir * homing_strength)

func activate():
	set_process(true)
	set_physics_process(true)
	monitorable = true
	monitoring = true
	visible = true
	body_pic.modulate = Color.WHITE
	activated = true
	lifetimeTimer.start()
	if onSpawnFunc.is_valid():
		onSpawnFunc.call(self)

func deactivate():
	if not activated:
		return
	activated = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	onSpawnFunc = Callable()
	move_override = Callable()
	var _tween : Tween = create_tween()
	_tween.tween_property(self,"move_spd", 0.0, 0.45)
	_tween.parallel().tween_property(body_pic, "modulate", Color.TRANSPARENT, 0.45 )
	await _tween.finished
	move_OverrideDir = Vector2.ZERO
	override_CustomValue = 0.0
	override_VeerStr = 0.0
	move_overrideDurMax = 0.0
	move_overrideDur = 0.0
	visible = false
	set_process(false)
	set_physics_process(false)
	returnedToPool.emit(self)


func _on_life_time_timeout():
	deactivate()
