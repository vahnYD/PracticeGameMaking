class_name Bullet
extends Area2D

@onready var collision: CollisionShape2D  = $CollisionShape
@onready var sprite: Sprite2D             = $Sprite

var bullet_name: String          = "unknown"
var mov_speed: float             = 225.0
var dmg_multiplier: float        = 1.0

var b_bonus_dmg: float           = 0.0

var onDestroy_effName: String    = "basic"

var actual_dmg: float            = 1.0

var mov_Dir: Vector2              = Vector2.RIGHT
var move_OverrideDir: Vector2
var isActive: bool = false

var MoveFunc: Callable = Callable()
var onSpawnFunc : Callable = Callable()

signal bullet_returned_toPool(Bullet)

func activate(_playerStr: float, _moveFunc : Callable, _onSpawnFunc : Callable):
	Bullet_dmg_calc(_playerStr)
	if _moveFunc.is_valid():
		MoveFunc = _moveFunc
	visible = true
	monitorable = true
	monitoring = true
	isActive = true
	if _onSpawnFunc.is_valid():
		onSpawnFunc = _onSpawnFunc
		onSpawnFunc.call(self)

func load_data_from_res(_BulletRes : Bullet_Res):
	bullet_name = _BulletRes.bullet_name
	mov_speed = _BulletRes.mov_speed
	dmg_multiplier = _BulletRes.dmg_multiplier
	
	collision.shape = _BulletRes.col_Shape    #  initially, the capsule is straight up
	collision.rotation_degrees = 90.0         #  rotate it so it lay sideway
	sprite.texture = _BulletRes.sprite_texture
	
	onDestroy_effName = _BulletRes.onDestroy_effName
	
	b_bonus_dmg = _BulletRes.b_bonus_dmg
	mov_Dir = _BulletRes.base_mov_Dir
	

func _process(delta):
	if not isActive:
		return
	
	if MoveFunc.is_valid():
		MoveFunc.call(self, delta)
	global_position += mov_Dir * mov_speed * delta
	

func Bullet_dmg_calc (_playerStr: float):
	actual_dmg = _playerStr * dmg_multiplier + b_bonus_dmg

func _on_area_entered(area):
	if area is Enemy:
		area.takeDamage(actual_dmg)
		deactivate()
	if area is Kill_Zone:
		deactivate()
		

func deactivate():
	if not isActive:
		return
	isActive = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	onSpawnFunc = Callable()
	MoveFunc = Callable()
	bullet_returned_toPool.emit(self)
