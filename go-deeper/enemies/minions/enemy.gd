class_name Enemy
extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprites
@onready var collisionZone: CollisionShape2D = $Collision
@onready var checkTimer: Timer = $checkTimer

var HP : float = 10.0
var mov_speed: float = 10.0
var ATK: float = 3.0
var atk_spd: float = 1.0
var DEF: float = 0.0
var enemy_name: String = "unknown"

var baseXscale: float = 0.222
var baseYscale: float = 0.222
var movDir : Vector2
var InitDistanceToPlayer: float
var CurDistanceToPlayer: float
var target_attackPoint : Vector2
var scale_increase: float = 0.0
var elapsedTime: float = 0.0

signal death(Enemy)

func load_data(_Enemy_dictionary: ScaledEnemyData):
	elapsedTime = 0.0
	sprite.sprite_frames = _Enemy_dictionary.sprite_frames
	mov_speed = _Enemy_dictionary.mov_speed
	ATK = _Enemy_dictionary.atk
	atk_spd = _Enemy_dictionary.atk_speed
	DEF = _Enemy_dictionary.def
	if _Enemy_dictionary.isSpecial > 1.0:
		collisionZone.shape = collisionZone.shape.duplicate()
		collisionZone.shape.radius *= _Enemy_dictionary.isSpecial
		scale = Vector2(baseXscale * _Enemy_dictionary.isSpecial, baseYscale * _Enemy_dictionary.isSpecial)
		HP = _Enemy_dictionary.hp * 10.0
	else:
		HP = _Enemy_dictionary.hp
		collisionZone.shape.radius = _Enemy_dictionary.collision_radius
		scale = Vector2(baseXscale, baseYscale)

func on_spawn():
	global_position.x += randf_range(-64, 64)
	get_moveDirection()
	checkTimer.start(0.133)
	scale = Vector2(baseXscale,baseYscale)


func _process(delta):
	mov_speed += elapsedTime / 100
	position += mov_speed * movDir * delta
	scaleCheck(delta)
	
func scaleCheck(delta):
	await get_tree().process_frame
	CurDistanceToPlayer = global_position.distance_to(target_attackPoint)
	if CurDistanceToPlayer/10 < 6.9:
		movDir = Vector2.ZERO
	else:
		elapsedTime += delta
		scale_increase = 1.0 - snapped(CurDistanceToPlayer/InitDistanceToPlayer, 0.001)
		scale = Vector2(baseXscale + scale_increase , baseYscale + scale_increase)

	
func get_moveDirection():
	await get_tree().process_frame
	var min_distance = INF
	var targets = []
	targets = get_tree().get_nodes_in_group("enemyAtkSpot")

	target_attackPoint = targets.pick_random().global_position
	InitDistanceToPlayer = global_position.distance_to(target_attackPoint)
	movDir = global_position.direction_to(target_attackPoint)

func on_die():
	death.emit(self)


func _on_check_timer_timeout():
	pass # Replace with function body.
