
class_name Base_Enemy
extends CharacterBody2D

@export var speed: float
@export var difficulty: int
@export var enemy_name: String

@onready var health = $HealthComponent
@onready var anim = $AnimatedSprite2D
@onready var hitbox = $HitboxComponent

enum State { IDLE, WALKING, HURT, DEAD }
var current_state = State.IDLE

var restlessnessLow: float = 1.5
var restlessnessHigh: float = 4
var aggroFloat: float
var move_timer: float = 0.0
var move_direction = Vector2.ZERO

func _init(p_name: String, p_speed: float, p_aggro: float, p_difficulty: int):
	enemy_name = p_name
	speed = p_speed
	aggroFloat = p_aggro
	difficulty = p_difficulty
	set_meta("difficulty", p_difficulty)
	
func _ready():

	health.took_damage.connect(_on_took_damage)
	health.died.connect(_on_died)
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if current_state == State.DEAD or current_state == State.HURT:
		return
		
	# Simple wandering AI
	move_timer -= delta
	if move_timer <= 0:
		move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		move_timer = randf_range(restlessnessLow, restlessnessHigh)
		await get_tree().create_timer(aggroFloat).timeout
		move_direction = Vector2.ZERO
		
	velocity = move_direction * speed
	move_and_slide()

	# Animation handling
	if velocity.length() > 0 and not current_state == State.HURT:
		if health.current_health > 0:
			current_state = State.WALKING
			anim.play("walking")
			anim.flip_h = velocity.x < 0
	else:
		if health.current_health > 0:
			current_state = State.IDLE
			anim.play("idle")

func _on_took_damage():
	if current_state != State.DEAD:
		current_state = State.HURT
		anim.play("hurt")
		
		

func _on_died():
	current_state = State.DEAD
	$CollisionShape2D.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	anim.stop()
	anim.play("death")

func _on_animation_finished():
	if anim.animation == "death" or health.current_health <= 0:
		anim.stop()
		call_deferred("free")
	elif anim.animation == "hurt":
		if current_state != State.DEAD:
			current_state = State.IDLE
