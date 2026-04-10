#player.gd
class_name PlayerCharacter
extends Area2D

@onready var shot_cd_timer: Timer = $shotCooldownTimer
@onready var bullet_shootMarker : Marker2D = $bullet_shootMarker

var can_atk: bool = false

var playscreensize_MAX: Vector2
const playscreen_offset : float = 128.0


var move_speed: float = 850.0
var accel_speed: float = 5444.0
var move_friction: float  = 6660.0
var cur_velocity: Vector2 = Vector2.ZERO

@export var Cur_bullets_res: Array[Bullet_Res]

## Player Stats below:

var basePlayerStr: float = 25.0
var PlayerStr: float = 25.0

## for now, 30. to add a bit of challenge for the prototype,
## adding a chance to lose. will be increased to 80 if
## the roguelike mechanics ever gets added.
var MaxHP: float = 30.0
var CurHP: float:
	set(value):
		# Clamp ensures health stays between 0 and max health
		CurHP = clamp(value, 0.0, MaxHP)
		
		#update_health_bar()
		
		if CurHP <= 0:
			pass
			die()
			
			
var CurDEF: float = 0.0
var baseDEF: float = 0.0

var CurPowerUpCount: int = 0
var CurPowerLevel: int = 0


func _ready():
	
	z_index = ZIndex_constants.PLAYER
	await get_tree().process_frame
	playscreensize_MAX = GameManager.viewport_size
	playscreensize_MAX.x -= 256.0
	playscreensize_MAX.y -= playscreen_offset
	shot_cd_timer.start()
	
	main_bullet_name = Cur_bullets_res[0].bullet_name
	side1_bullet_name = Cur_bullets_res[1].bullet_name
	side2_bullet_name = Cur_bullets_res[2].bullet_name
	first_offset = Vector2(-spawnOffset * 0.33, spawnOffset * 0.66)
	second_offset = Vector2(-spawnOffset * 0.66, spawnOffset * 1.11)
	
	## Setup Stats:
	CurHP = MaxHP
	CurDEF = baseDEF
	
var isAlive: bool = true
func _process(delta):
	if not isAlive:
		return
	var input_dir = Input.get_vector("go_LEFT", "go_RIGHT", "go_UP", "go_DOWN")
	if input_dir != Vector2.ZERO:
		cur_velocity = cur_velocity.move_toward(input_dir * move_speed, accel_speed * delta)
	else:
		cur_velocity = cur_velocity.move_toward(Vector2.ZERO, move_friction * delta)
		
	global_position += cur_velocity * delta
	global_position = global_position.clamp(Vector2(playscreen_offset,playscreen_offset), playscreensize_MAX)
	
	if Input.is_action_pressed("basic_attack") and can_atk:
		basic_attack(delta)


#region basic bullet variables
var main_bullet_name: String
var side1_bullet_name: String
var side2_bullet_name: String
var shot_WaveInterval : float
var init_bul_spawnPos : Vector2
const spawnOffset: float = 128.0
const YFlip : Vector2 = Vector2(1,-1)
var first_offset: Vector2 
var second_offset: Vector2 
#endregion

func basic_attack(_delta):
	shot_WaveInterval += _delta
	can_atk = false
	
	init_bul_spawnPos = bullet_shootMarker.global_position
	
	match CurPowerLevel:
		0:	shot_lv1()
		1:	shot_lv2()
		2:	shot_lv3()
		3:	shot_lv4()
		4:	shot_lv5()
		
	shot_cd_timer.start()
	
#region Shot Patterns
	
func shot_lv1():
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos)
	
func shot_lv2():
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos)
	await get_tree().create_timer(0.06).timeout
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + Vector2(-88.0, 0))
	
func shot_lv3():
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos)
	await get_tree().create_timer(0.05).timeout
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + first_offset)
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + first_offset * YFlip)

func shot_lv4():
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos)
	await get_tree().create_timer(0.03).timeout
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + first_offset)
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + first_offset * YFlip)
	await get_tree().create_timer(0.03).timeout
	BulletPool.put_bullet_toGame(side2_bullet_name,PlayerStr,init_bul_spawnPos + second_offset)
	BulletPool.put_bullet_toGame(side2_bullet_name,PlayerStr,init_bul_spawnPos + second_offset * YFlip)
	
var lastOffset : Vector2 = Vector2(0.0,36.0)
func shot_lv5():
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos + lastOffset )
	BulletPool.put_bullet_toGame(main_bullet_name,PlayerStr,init_bul_spawnPos + lastOffset * YFlip)
	await get_tree().create_timer(0.03).timeout
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + lastOffset + first_offset)
	BulletPool.put_bullet_toGame(side1_bullet_name,PlayerStr,init_bul_spawnPos + (lastOffset + first_offset) * YFlip)
	await get_tree().create_timer(0.03).timeout
	BulletPool.put_bullet_toGame(side2_bullet_name,PlayerStr,init_bul_spawnPos + lastOffset + second_offset)
	BulletPool.put_bullet_toGame(side2_bullet_name,PlayerStr,init_bul_spawnPos + (lastOffset + second_offset) * YFlip)	
#endregion

func update_bullet(_bullet_name: String, _newData: Bullet_Res):
	pass
	

func receive_damage(_dmgAmount: float):
	pass

signal hurt(value: float)
func _on_area_entered(area):
	if area is Enemy:
		CurHP -= maxf(area.ATK - CurDEF, 1.0)
		hurt.emit(area.ATK)
		area.deactivate()
	if area is Power_Up:
		gainPower(area.UpValue)
		await get_tree().process_frame
		area.call_deferred("queue_free")

func gainPower(_UpValue: int):
	CurPowerUpCount += _UpValue
	
	powerLevelChange()

		
func powerLevelChange():
	PlayerStr = basePlayerStr + (CurPowerUpCount * 0.7)
	CurDEF  = baseDEF + (CurPowerUpCount * 0.05)
	if CurPowerUpCount <= 3:
		CurPowerLevel = 0
	elif CurPowerUpCount <= 9:
		CurPowerLevel = 1
	elif CurPowerUpCount <= 24:
		CurPowerLevel = 2
	elif CurPowerUpCount <= 45:
		CurPowerLevel = 3
	elif CurPowerUpCount <= 69:
		CurPowerLevel = 4

func _on_shot_cooldown_timer_timeout():
	can_atk = true

func die():
	isAlive = false
	var death_tween: Tween = create_tween()
	death_tween.tween_property(self,"modulate:a",0.05,1.4)
	await death_tween.finished
	process_mode = Node.PROCESS_MODE_DISABLED
	
