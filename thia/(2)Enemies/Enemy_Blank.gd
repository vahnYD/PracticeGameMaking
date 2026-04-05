# Enemy_Blank.gd
class_name Enemy
extends Area2D

var enemy_name: String = "unknown"
var HP: float = 10.0
var max_HP: float = 10.0
var ATK: float = 5.0
var DEF: float = 0.0
var move_spd: float = 300.0
var move_type: GlobalTypes.enemy_move_types = GlobalTypes.enemy_move_types.straight

var move_override: Callable
var move_overrideDur: float = 0.0
var override_CustomValue: float = 0.0

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

var actived: bool = false
var isSpecial: float = 0.0

signal returnedToPool(Enemy)


func load_data(_enemy_dict : EnemyScaledData):
	
	if _enemy_dict.move_Override.is_valid():
		move_override = _enemy_dict.move_Override
		move_overrideDur = _enemy_dict.move_overrideDur
		
	else:
		move_override = Callable()
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
	if move_override.is_valid() and move_overrideDur > 0:
		move_overrideDur -= delta
		move_override.call(self, delta)
		
	global_position += move_dir.normalized() * move_spd * delta

	
func basic_movement():
	if move_overrideDur <= 0:
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
	actived = true
	lifetimeTimer.start()

func deactivate():
	monitorable = false
	monitoring = false
	actived = false
	var _tween : Tween = create_tween()
	_tween.tween_property(self,"move_spd", 0.0, 0.45)
	_tween.parallel().tween_property(body_pic, "modulate", Color.TRANSPARENT, 0.45 )
	await _tween.finished
	visible = false
	set_process(false)
	set_physics_process(false)
	returnedToPool.emit(self)


func _on_life_time_timeout():
	deactivate()
