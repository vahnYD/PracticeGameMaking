# Enemy.gd
# Attach to a CharacterBody2D node named "Enemy"
# Handles movement toward player, health, damage dealing, and death.
class_name Enemy
extends CharacterBody2D

signal died(xp_reward: int)

var data: EnemyData = null
var health: float = 10.0
var player: Node2D = null

# Visual nodes (created procedurally since we have no sprites)
var _body_rect: ColorRect
var _health_bar_bg: ColorRect
var _health_bar_fg: ColorRect
var _label: Label

func setup(enemy_data: EnemyData, player_node: Node2D) -> void:
	data = enemy_data
	player = player_node
	health = data.max_health
	_build_visuals()

func _build_visuals() -> void:
	# Body
	_body_rect = ColorRect.new()
	_body_rect.color = data.color
	_body_rect.size = data.size
	_body_rect.position = -data.size / 2.0
	add_child(_body_rect)

	# Name label
	_label = Label.new()
	_label.text = data.display_name[0]  # First letter abbreviation
	_label.position = Vector2(-6, -data.size.y / 2.0 - 2)
	_label.add_theme_font_size_override("font_size", 10)
	add_child(_label)

	# Health bar background
	var bar_width = data.size.x
	_health_bar_bg = ColorRect.new()
	_health_bar_bg.color = Color(0.2, 0.0, 0.0)
	_health_bar_bg.size = Vector2(bar_width, 4)
	_health_bar_bg.position = Vector2(-bar_width / 2.0, data.size.y / 2.0 + 2)
	add_child(_health_bar_bg)

	_health_bar_fg = ColorRect.new()
	_health_bar_fg.color = Color(0.0, 0.8, 0.0)
	_health_bar_fg.size = Vector2(bar_width, 4)
	_health_bar_fg.position = _health_bar_bg.position
	add_child(_health_bar_fg)

	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = data.size
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	if player == null or data == null:
		return
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * data.move_speed
	move_and_slide()

func take_damage(amount: float) -> void:
	health -= amount
	var pct = clampf(health / data.max_health, 0.0, 1.0)
	_health_bar_fg.size.x = _health_bar_bg.size.x * pct
	_health_bar_fg.color = Color(1.0 - pct, pct * 0.8, 0.0)
	if health <= 0.0:
		emit_signal("died", data.xp_reward)
		queue_free()

func get_damage() -> float:
	return data.damage if data else 0.0
