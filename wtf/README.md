# Vampire Survivors Demo — GDScript (Godot 4.x)

## Setup Instructions

1. Open **Godot 4.x** (4.1+)
2. Import project: Point to this folder's `project.godot`
3. The main scene is `scenes/Game.tscn` — it auto-builds everything in code
4. Press **F5** to run

## Controls
- **Arrow Keys** — Move
- Auto-attack targets the nearest enemy within range

---

## Architecture Overview

```
scripts/
  EnemyData.gd      — Enemy stat definitions (registry pattern)
  SpawnWave.gd      — Single wave/pattern resource
  LevelData.gd      — Level config + wave sequences (registry pattern)
  Enemy.gd          — Enemy CharacterBody2D logic
  Player.gd         — Player CharacterBody2D logic
  SpawnManager.gd   — Wave timer + enemy spawning
  GameScene.gd      — Root scene controller, UI, state machine
```

---

## How to Add a New Enemy

1. Open `scripts/EnemyData.gd`
2. Add a static factory method:
```gdscript
static func _make_vampire() -> EnemyData:
	var d = EnemyData.new()
	d.enemy_id = "vampire"
	d.display_name = "Vampire"
	d.max_health = 60.0
	d.move_speed = 90.0
	d.damage = 20.0
	d.xp_reward = 4
	d.color = Color(0.5, 0.0, 0.5)
	d.size = Vector2(20, 30)
	return d
```
3. Register it in `get_all()`:
```gdscript
static func get_all() -> Dictionary:
	return {
		"slime": _make_slime(),
		"goblin": _make_goblin(),
		"skeleton": _make_skeleton(),
		"vampire": _make_vampire(),  # <-- add here
	}
```
4. Reference `"vampire"` in any SpawnWave's `enemy_ids`.

---

## How to Add a New Level

1. Open `scripts/LevelData.gd`
2. Add a static factory method:
```gdscript
static func _make_level3() -> LevelData:
	var l = LevelData.new()
	l.level_id = 3
	l.display_name = "Skeleton Crypt"
	l.bg_color = Color(0.05, 0.05, 0.12)
	l.bg_accent_color = Color(0.08, 0.08, 0.18)
	l.duration_sec = 180.0
	
	var wave = SpawnWave.new()
	wave.enemy_ids = ["skeleton", "goblin", "vampire"]
	wave.count = 18
	wave.interval_sec = 2.0
	wave.start_at_sec = 0.0
	wave.end_at_sec = -1.0
	l.spawn_waves = [wave]
	return l
```
3. Register it in `get_all()`:
```gdscript
static func get_all() -> Array:
	return [
		_make_level1(),
		_make_level2(),
		_make_level3(),  # <-- add here
	]
```

---

## SpawnWave Fields

| Field | Type | Description |
|---|---|---|
| `enemy_ids` | Array[String] | Pool of enemy types to randomly pick from |
| `count` | int | Enemies per spawn tick |
| `interval_sec` | float | Seconds between spawns |
| `start_at_sec` | float | Level time when this wave activates |
| `end_at_sec` | float | Level time when this wave stops (-1 = never) |

You can stack multiple waves per level to create phases (e.g., wave1 active 0–60s, wave2 active 60s+).
