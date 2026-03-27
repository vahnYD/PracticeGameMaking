# SpawnManager.gd
# Attach to a Node2D in the game scene.
# Reads SpawnWave definitions from LevelData and spawns enemies over time.
class_name SpawnManager
extends Node2D

const SPAWN_MARGIN: float = 60.0

var level_data: LevelData = null
var player: Node2D = null
var level_elapsed: float = 0.0
var active: bool = false

# Per-wave countdown timers indexed by wave index
var _wave_timers: Array = []

func start(data: LevelData, player_node: Node2D) -> void:
	level_data = data
	player = player_node
	level_elapsed = 0.0
	active = true
	_wave_timers.clear()
	for i in level_data.spawn_waves.size():
		_wave_timers.append(0.0)

func stop() -> void:
	active = false

func _process(delta: float) -> void:
	if not active or level_data == null:
		return
	level_elapsed += delta
	for i in level_data.spawn_waves.size():
		var wave: SpawnWave = level_data.spawn_waves[i]
		if level_elapsed < wave.start_at_sec:
			continue
		if wave.end_at_sec >= 0.0 and level_elapsed >= wave.end_at_sec:
			continue
		_wave_timers[i] -= delta
		if _wave_timers[i] <= 0.0:
			_wave_timers[i] = wave.interval_sec
			_spawn_wave(wave)

func _spawn_wave(wave: SpawnWave) -> void:
	for j in wave.count:
		var enemy_id = wave.pick_enemy()
		_spawn_enemy(enemy_id)

func _spawn_enemy(enemy_id: String) -> void:
	
	var enemy_data = EnemyData.theget(enemy_id)
	if enemy_data == null:
		push_warning("SpawnManager: Unknown enemy id: " + enemy_id)
		return
	var e = CharacterBody2D.new()
	e.set_script(load("res://scripts/Enemy.gd"))
	e.add_to_group("enemies")
	get_parent().add_child(e)
	e.setup(enemy_data, player)
	e.global_position = _random_spawn_position()
	e.died.connect(_on_enemy_died)

func _on_enemy_died(xp_reward: int) -> void:
	if player and player.has_method("add_xp"):
		player.add_xp(xp_reward)

func _random_spawn_position() -> Vector2:
	var vp = get_viewport().get_visible_rect()
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(vp.position.x, vp.end.x), vp.position.y - SPAWN_MARGIN)
		1: return Vector2(randf_range(vp.position.x, vp.end.x), vp.end.y + SPAWN_MARGIN)
		2: return Vector2(vp.position.x - SPAWN_MARGIN, randf_range(vp.position.y, vp.end.y))
		_: return Vector2(vp.end.x + SPAWN_MARGIN, randf_range(vp.position.y, vp.end.y))
