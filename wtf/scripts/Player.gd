# Player.gd
# Attach to a CharacterBody2D node named "Player"
# Handles movement, auto-attack, XP, leveling.
class_name Player
extends CharacterBody2D

signal xp_changed(current: int, to_next: int)
signal level_changed(new_level: int)
signal health_changed(current: float, max_val: float)
signal died

const MOVE_SPEED: float = 150.0
const BASE_HEALTH: float = 100.0
const BASE_ATTACK_DAMAGE: float = 20.0
const ATTACK_RANGE: float = 120.0
const ATTACK_RATE: float = 1.0  # attacks per second

var health: float = BASE_HEALTH
var max_health: float = BASE_HEALTH
var xp: int = 0
var player_level: int = 1
var xp_to_next: int = 10

var _attack_cooldown: float = 0.0
var _body_rect: ColorRect
var _attack_radius_hint: ColorRect  # subtle ring hint

func _ready() -> void:
	_build_visuals()
	# Collision
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 28)
	col.shape = shape
	add_child(col)

func _build_visuals() -> void:
	_body_rect = ColorRect.new()
	_body_rect.color = Color(0.2, 0.5, 0.9)
	_body_rect.size = Vector2(20, 28)
	_body_rect.position = Vector2(-10, -14)
	add_child(_body_rect)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_attack(delta)

func _handle_movement(delta: float) -> void:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_action_pressed("ui_right"): dir.x += 1
	if Input.is_action_pressed("ui_up"):    dir.y -= 1
	if Input.is_action_pressed("ui_down"):  dir.y += 1
	if dir != Vector2.ZERO:
		dir = dir.normalized()
	velocity = dir * MOVE_SPEED
	move_and_slide()

func _handle_attack(delta: float) -> void:
	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return
	# Find closest enemy
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var closest_dist = ATTACK_RANGE
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = e
	if closest:
		_attack_cooldown = 1.0 / ATTACK_RATE
		_do_attack(closest)

func _do_attack(target: Node2D) -> void:
	# Damage scaled by player level
	var dmg = BASE_ATTACK_DAMAGE * (1.0 + (player_level - 1) * 0.2)
	target.take_damage(dmg)
	# Spawn a quick visual projectile line
	_flash_attack_line(target.global_position)

func _flash_attack_line(target_pos: Vector2) -> void:
	# Simple flash dot at attack target position
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 0.2, 0.8)
	flash.size = Vector2(8, 8)
	get_parent().add_child(flash)
	flash.global_position = target_pos - Vector2(4, 4)
	var tween = get_tree().create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.15)
	tween.tween_callback(flash.queue_free)

func take_damage(amount: float) -> void:
	health -= amount
	health = maxf(health, 0.0)
	emit_signal("health_changed", health, max_health)
	_body_rect.color = Color(0.9, 0.2, 0.2)
	var tween = get_tree().create_tween()
	tween.tween_property(_body_rect, "color", Color(0.2, 0.5, 0.9), 0.2)
	if health <= 0.0:
		emit_signal("died")

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		_level_up()
	emit_signal("xp_changed", xp, xp_to_next)

func _level_up() -> void:
	player_level += 1
	xp_to_next = int(xp_to_next * 1.5)
	max_health += 20.0
	health = min(health + 30.0, max_health)
	emit_signal("level_changed", player_level)
	emit_signal("health_changed", health, max_health)
