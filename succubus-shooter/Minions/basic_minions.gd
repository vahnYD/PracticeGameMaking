class_name  basic_minion
extends Area2D

@export var MinionData: MinionResource
@export var movSpeed_curve: Curve

var specific_MinionName: String
var specific_base_speed: float = 0.0
var specific_base_touchDamage: float = 0
var specific_animationsFrames: SpriteFrames
var specific_powers: Array[MinionResource.basic_power] = [MinionResource.basic_power.none]
var specific_lifetime: float = 3.0
var specific_movOverrideTimer: float = 0.0
var specific_movement_override: Callable

var specific_movementType: global_enums.Minion_moveType = global_enums.Minion_moveType.basic

@onready var specific_HitboxComponent : HitboxComponent = $HitboxComponent
@onready var specific_animationPlay : AnimatedSprite2D = $AnimatedSprite
@onready var specific_HealthComponent : HealthComponent = $HealthComponent
@onready var specific_playerDmgCollissionBox: CollisionShape2D = $PlayerDmgBox
@onready var HitBox: CollisionShape2D = $HitboxComponent/Hitbox
var movedir : Vector2

#region ifMovetypeIsRandom

var veer_timer: float = 1.2
var veer_timer_reset: float = 1.2

var veer_intensity: float = 0.8
var veer_intensity_reset: float = 0.8

var veer_chance: float = 0.7 # (70%)

var veer_direction = Vector2.ZERO
#endregion


#region ifMovetypeIsFrozen
var frozeTimer : float  = 0.0
#endregion


var actualMoveType: global_enums.Minion_moveType = global_enums.Minion_moveType.basic

const blankMinionData: MinionResource = preload("res://Minions/blankMinionData.tres")

signal returned_minion_to_pool(this_minion: Area2D)

var isActivated: bool = false

var initialHaste: float
var adjustStr: float # -1 means spawned from the top, 0 means spawned from the Center, 1 means spawned from the Bottom
var screenCenter: Vector2
var checktimer: float  = 1.0
func _physics_process(delta):

	match specific_movementType:
		global_enums.Minion_moveType.basic:
			movedir = -transform.x
		global_enums.Minion_moveType.random:
			randomMovement(delta)
		global_enums.Minion_moveType.frozen:
			frozeTimer -= delta
			if frozeTimer <= 0:
				specific_movementType = actualMoveType
			else:
				movedir = Vector2.ZERO
	if initialHaste > 0  and adjustStr != 0 and not specific_movement_override.is_valid():
		initialHaste -= delta
		goToCenter()
	if specific_movement_override.is_valid():
		if specific_movOverrideTimer > 0:
			specific_movOverrideTimer-= delta
			specific_movement_override.call(self, delta)

	# Apply final movement
	if movedir != Vector2.ZERO:
		global_position += movedir.normalized() * specific_base_speed * delta
	specific_lifetime -= delta
	if specific_lifetime <= 0 and isActivated: 
		minion_death()

func goToCenter():
	#veer_direction = global_position.direction_to(screenCenter) * 0.2 * adjustStr
	#movedir += veer_direction
	movedir += Vector2(0,sign(global_position.y-screenCenter.y))

func randomMovement(delta):
		if veer_timer > 0:
			# Apply the veer direction
			movedir += veer_direction * veer_intensity 
			veer_timer -= delta
		else:
			# Randomly trigger a veer
			if randf() < veer_chance:
				veer_direction = Vector2(randi_range(-1,1),randi_range(-1,1)) 
			veer_timer = veer_timer_reset


func _ready():
	screenCenter = GlobalScripts.max_ScreenSize / 2.0
	#if MinionData:
		#load_miniondata_from_resource(MinionData)
		#specific_animationPlay.play("default")
		#specific_playerDmgCollissionBox.disabled = false
		#HitBox.disabled = false


func load_miniondata_from_resource(res: MinionResource):
	
	# reset HP and lifetime so they dont die suddenly
	specific_HealthComponent.max_health = res.base_max_health
	specific_HealthComponent.current_health = res.base_max_health
	specific_lifetime = res.lifeTime
	specific_base_touchDamage = res.base_touchDamage
	# change the minion if its different
	if not specific_MinionName == res.base_MinionName:
		specific_MinionName = res.base_MinionName
		specific_base_speed = res.base_speed
		specific_powers = res.powers
		specific_animationsFrames = res.animations
		specific_animationPlay.sprite_frames = specific_animationsFrames
		specific_movementType = res.move_type
		frozeTimer = res.freeze_time
		
		if not res.base_MinionName == "Unknown":
			specific_playerDmgCollissionBox.shape = res.collision_shape.duplicate()
			HitBox.shape = res.collision_shape.duplicate()
			HitBox.shape.radius += 12.0
			if not specific_HealthComponent.died.is_connected(minion_death):
				specific_HealthComponent.died.connect(minion_death)
	

func player_Hit(player: PlayerCharacter):
	player.takeDamage(specific_base_touchDamage)
	

func minion_death():
	deactivate_minion()

func deactivate_minion() -> void:
	isActivated = false
	specific_animationPlay.play("death")
	# disable all collission :
	specific_playerDmgCollissionBox.set_deferred("disabled",true)
	HitBox.set_deferred("disabled",true)
	set_process(false)
	set_physics_process(false)
	
	#make enemy fade
	var _this_tween: Tween = get_tree().create_tween()
	_this_tween.tween_property(self,"modulate", Color.TRANSPARENT, 0.225)
	_this_tween.parallel().tween_property(self,"global_position", global_position + Vector2(12,12), 0.225)
	await _this_tween.finished
	call_deferred("hide")
	global_position = Vector2(1000,-256)
	
	# returns all custom movement variables to normal
	veer_timer = veer_timer_reset
	veer_intensity = veer_intensity_reset
	#load_miniondata_from_resource(blankMinionData)

	returned_minion_to_pool.emit(self)


func spawn(pos: Vector2, movementOverride: Callable = Callable(), onSpawn: Callable = Callable()) -> void:
	global_position = pos
	specific_movement_override = movementOverride
	if global_position.y < 0:
		adjustStr = global_position.y / 100.0 * -1
	if global_position.y > GlobalScripts.max_ScreenSize.y :
		adjustStr = (GlobalScripts.max_ScreenSize.y - global_position.y ) / 100 * -1
	initialHaste = abs(adjustStr)
	z_index = 2
	specific_playerDmgCollissionBox.disabled = false
	HitBox.disabled = false
	call_deferred("show")
	set_process(true)
	set_physics_process(true)
	specific_animationPlay.play("default")
	var _this_tween: Tween = get_tree().create_tween()
	_this_tween.tween_property(self,"modulate", Color.WHITE, 0.08)
	isActivated = true
	
	if onSpawn.is_valid():
		onSpawn.call(self)

func _on_hitbox_component_area_entered(area):
	if area.is_in_group("Bullet"):
		specific_HealthComponent.take_damage(area.get_parent().specific_damage)
	if area.is_in_group("KillZone"):
		deactivate_minion()

func _on_body_entered(body):
	if body.is_in_group("thePlayer"):
		player_Hit(body)
		deactivate_minion()
