class_name PlayerCharacter
extends CharacterBody2D

@onready var playScreen: Vector2 
@onready var WingsSprite : AnimatedSprite2D = $Wings
@onready var BodySprite : AnimatedSprite2D = $Body
@onready var BulletSpawnMarker : Marker2D = $Marker2D
var bulletSpawnPosition: Vector2

@export var bullet_resources : Array[BulletResource] = []

@export var chara_name: String
@export var ATK: float
@export var MaxHealth: float

var curHealth : float

@export var DEF: float

@export var move_speed : float = 800
@export var attack_cooldown: float = 0.1333
@export var currentPowerBuff: int = 0 # decides what pattern of bullet you shoot
@export var MaxPowerBuff: int = 5
var HeartCount: int # Heart increase PowerBuff
var main_bullet_Piercing_ON : bool = false

signal HPChanged(newCurHP: float, newMaxHP: float)
signal Death

const _BulletOffset: Array[Vector2] = [Vector2(-16,-64), Vector2(-16,64)]
const acceleration: float = 5250


var _Movement_direction : Vector2
var TemporaryPowerupTimer : float = 1 #fully temprorary, lol
var _shotDelay: float = 0
func _ready():
	curHealth = MaxHealth
	bulletSpawnPosition = BulletSpawnMarker.global_position
	playScreen = get_viewport_rect().size
	await get_tree().process_frame
	playScreen.y -= 128
	playScreen.x -= 256


func MovingAnimation():
	if get_real_velocity().length() > 690:
		WingsSprite.play("fast")
	else:
		WingsSprite.play("slow")
	pass
	
	if velocity.x > 120:
		if Input.is_action_pressed("attack"):
			BodySprite.play("attack_forward")
		else:
			BodySprite.play("go_forward")
	elif velocity.x < -120:
		if Input.is_action_pressed("attack"):
			BodySprite.play("attack_back")
		else:
			BodySprite.play("go_back")
	else :
		if Input.is_action_pressed("attack"):
			BodySprite.play("attack_back")
		else:
			BodySprite.play("default")
	

func _physics_process(delta):
	if curHealth <= 0:
		return
	_Movement_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	bulletSpawnPosition = BulletSpawnMarker.global_position
	velocity = velocity.move_toward(_Movement_direction * move_speed, acceleration * delta)
	move_and_slide()
	position = position.clamp(Vector2(128,128), playScreen)


func _process(delta):
	if curHealth <= 0:
		return
	MovingAnimation()
	_shotDelay += delta
	TemporaryPowerupTimer -= delta
	if TemporaryPowerupTimer <= 0 and currentPowerBuff < 5:
		PowerUp()
		TemporaryPowerupTimer = 1.0

	if Input.is_action_pressed("attack") and _shotDelay >= attack_cooldown :
		if currentPowerBuff == 0:
			shotPattern_lv1()
		elif currentPowerBuff == 1:
			shotPattern_lv2()
		elif currentPowerBuff == 2:
			shotPattern_lv3()
		elif currentPowerBuff == 3:
			shotPattern_lv4()
		elif currentPowerBuff == 4:
			shotPattern_lv5()
		elif currentPowerBuff == 5:
			shotPattern_lv6()
		_shotDelay = 0

func shot_bullet(bullet_name: String, bullet_pos: Vector2, bullet_angle: float, Dmg: float) -> void:
	# calls BulletPool class to put the bullet into the game, MainBullet first at SpawnMarker, forward (angle = 0)
	if bullet_name == "basic big":
		BulletPool.put_bullet_toGame("basic big", bullet_pos, bullet_angle, Dmg, func(b: Bullet):
			if main_bullet_Piercing_ON and b.specific_ability != BulletResource.Ability_list.Piercing:
				b.specific_ability = BulletResource.Ability_list.Piercing
				b.modulate = Color.WHITE.lerp(Color.DEEP_PINK, 0.4) )
	else:
		BulletPool.put_bullet_toGame(bullet_name, bullet_pos , bullet_angle, Dmg)		


func PowerUp():
	currentPowerBuff += 1
	if currentPowerBuff >= 5:
		main_bullet_Piercing_ON = true
		BulletPool.modify_bullets("basic big", func(bullet: Bullet):
			bullet.specific_ability = BulletResource.Ability_list.Piercing
			bullet.modulate = Color.WHITE.lerp(Color.DEEP_PINK, 0.4) )
	else:
		main_bullet_Piercing_ON = false


#region BulletPatterns 
func shotPattern_lv1():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition,0,ATK)
	
func shotPattern_lv2():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition,0,ATK)
	await get_tree().create_timer(0.05).timeout
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition,0,ATK)
	
func shotPattern_lv3():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition,0,ATK)
	await get_tree().create_timer(0.04).timeout
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[0],0,ATK)
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[1],0,ATK)

func shotPattern_lv4():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition,0,ATK)
	await get_tree().create_timer(0.04).timeout
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[0],0,ATK)
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[1],0,ATK)
	await get_tree().create_timer(0.03).timeout
	shot_bullet(bullet_resources[2].bullet_name , bulletSpawnPosition + _BulletOffset[0] * 1.7,0,ATK)
	shot_bullet(bullet_resources[2].bullet_name , bulletSpawnPosition + _BulletOffset[1] * 1.7,0,ATK)

func shotPattern_lv5():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition,0,ATK)
	await get_tree().create_timer(0.04).timeout
	shot_bullet(bullet_resources[1].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 1.5,0,ATK)
	shot_bullet(bullet_resources[1].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 1.5,0,ATK)
	await get_tree().create_timer(0.023).timeout
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 0.65 , 0,ATK) 
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 0.65 , 0,ATK)
	await get_tree().create_timer(0.03).timeout
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[0] * 2,-0.5,ATK)
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[1] * 2, 0.5,ATK)
	await get_tree().create_timer(0.03).timeout
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 3, -1,ATK) 
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 3, 1,ATK)

func shotPattern_lv6():
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 0.65,0,ATK)
	shot_bullet(bullet_resources[0].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 0.65,0,ATK)
	await get_tree().create_timer(0.04).timeout
	shot_bullet(bullet_resources[1].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 1.5,-0.5,ATK)
	shot_bullet(bullet_resources[1].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 1.5,0.5,ATK)
	await get_tree().create_timer(0.03).timeout
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[0] * 2.5,-1,ATK)
	shot_bullet(bullet_resources[1].bullet_name , bulletSpawnPosition + _BulletOffset[1] * 2.5,1,ATK)
	await get_tree().create_timer(0.03).timeout
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[0] * 3.5, -2,ATK) 
	shot_bullet(bullet_resources[2].bullet_name, bulletSpawnPosition + _BulletOffset[1] * 3.5, 2,ATK)
#endregion


func takeDamage(dmgValue: float):
	if curHealth <= dmgValue:
		curHealth = 0
		death()
	else:
		curHealth -= dmgValue
	HPChanged.emit(curHealth, MaxHealth)

func death():
	BodySprite.play("death")
	var _tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.425)
	_tween.tween_callback(queue_free)
