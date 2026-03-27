# LevelData.gd
# Defines a level configuration. Add new levels by registering them in get_all().
class_name LevelData
extends Resource

@export var level_id: int = 1
@export var display_name: String = "Level 1"
@export var bg_color: Color = Color(0.1, 0.15, 0.1)
@export var bg_accent_color: Color = Color(0.08, 0.12, 0.08)
@export var duration_sec: float = 120.0
@export var spawn_waves: Array[SpawnWave] = []

# Static level registry — add new levels here
static func get_all() -> Array:
	return [
		_make_level1(),
		_make_level2(),
		# _make_level3(),
	]

static func get_by_id(id: int) -> LevelData:
	for l in get_all():
		if l.level_id == id:
			return l
	return null

# LEVEL 1 — Slime Meadow: only slimes, 10 per batch every 3s
static func _make_level1() -> LevelData:
	var l = LevelData.new()
	l.level_id = 1
	l.display_name = "Slime Meadow"
	l.bg_color = Color(0.05, 0.18, 0.05)
	l.bg_accent_color = Color(0.08, 0.22, 0.07)
	l.duration_sec = 120.0
	var w = SpawnWave.new()
	w.enemy_ids.append("slime")
	w.count = 10
	w.interval_sec = 3.0
	w.start_at_sec = 0.0
	w.end_at_sec = -1.0
	l.spawn_waves.append(w)
	return l

# LEVEL 2 — Goblin Forest: slimes+goblins early, all three later
static func _make_level2() -> LevelData:
	var l = LevelData.new()
	l.level_id = 2
	l.display_name = "Goblin Forest"
	l.bg_color = Color(0.12, 0.08, 0.04)
	l.bg_accent_color = Color(0.18, 0.10, 0.04)
	l.duration_sec = 150.0
	# Phase 1: 0-60s slimes + goblins, 12 per wave
	var w1 = SpawnWave.new()
	w1.enemy_ids.append("slime")
	w1.enemy_ids.append("goblin")
	w1.count = 12
	w1.interval_sec = 3.0
	w1.start_at_sec = 0.0
	w1.end_at_sec = 60.0
	# Phase 2: 60s+ all enemies, 15 per wave, faster
	var w2 = SpawnWave.new()
	w2.enemy_ids.append("slime")
	w2.enemy_ids.append("goblin")
	w2.enemy_ids.append("skeleton")
	w2.count = 15
	w2.interval_sec = 2.5
	w2.start_at_sec = 60.0
	w2.end_at_sec = -1.0
	l.spawn_waves.append(w1)
	l.spawn_waves.append(w2)
	return l

# TEMPLATE — copy and customize for Level 3+:
# static func _make_level3() -> LevelData:
#     var l = LevelData.new()
#     l.level_id = 3
#     l.display_name = "Skeleton Crypt"
#     l.bg_color = Color(0.05, 0.05, 0.12)
#     l.bg_accent_color = Color(0.07, 0.07, 0.18)
#     l.duration_sec = 180.0
#     var w = SpawnWave.new()
#     w.enemy_ids = ["skeleton", "goblin"]
#     w.count = 14
#     w.interval_sec = 2.5
#     w.start_at_sec = 0.0
#     l.spawn_waves = [w]
#     return l
