# EnemyData.gd
# Resource class defining enemy stats. Add new enemy types here.
class_name EnemyData
extends Resource

@export var enemy_id: String = ""          # Unique identifier: "slime", "goblin", "skeleton"
@export var display_name: String = ""
@export var max_health: float = 10.0
@export var move_speed: float = 60.0
@export var damage: float = 5.0
@export var xp_reward: int = 1
@export var color: Color = Color.WHITE     # Placeholder color (replace with sprite)
@export var size: Vector2 = Vector2(24, 24)

# Static registry of all enemy types
# To add a new enemy: add a new entry here
static func get_all() -> Dictionary:
	return {
		"slime": _make_slime(),
		"goblin": _make_goblin(),
		"skeleton": _make_skeleton(),
		# ADD NEW ENEMIES HERE:
		# "vampire": _make_vampire(),
	}

static func theget(id: String) -> EnemyData:
	return get_all().get(id, null)

static func _make_slime() -> EnemyData:
	var d = EnemyData.new()
	d.enemy_id = "slime"
	d.display_name = "Slime"
	d.max_health = 15.0
	d.move_speed = 50.0
	d.damage = 5.0
	d.xp_reward = 1
	d.color = Color(0.2, 0.8, 0.2)
	d.size = Vector2(20, 16)
	return d

static func _make_goblin() -> EnemyData:
	var d = EnemyData.new()
	d.enemy_id = "goblin"
	d.display_name = "Goblin"
	d.max_health = 25.0
	d.move_speed = 80.0
	d.damage = 10.0
	d.xp_reward = 2
	d.color = Color(0.6, 0.4, 0.1)
	d.size = Vector2(18, 24)
	return d

static func _make_skeleton() -> EnemyData:
	var d = EnemyData.new()
	d.enemy_id = "skeleton"
	d.display_name = "Skeleton"
	d.max_health = 40.0
	d.move_speed = 65.0
	d.damage = 15.0
	d.xp_reward = 3
	d.color = Color(0.9, 0.9, 0.85)
	d.size = Vector2(20, 28)
	return d
