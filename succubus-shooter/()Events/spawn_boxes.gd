extends Node2D

@export var minion_res: MinionResource
var spawn_queue = []
var _spawnTimer: float = 0.0
var SPAWN_INTERVAL: float = 0.05

var screen_size :Vector2 
var margin :float = 128.0
var zone_size :float = 512.0



func spawn_enemies_in_random_zone(enemy_count: int):
	if minion_res == null:
		push_error("Enemy scene is not assigned!")
		return
	
	screen_size = get_viewport().get_visible_rect().size
	
	var min_x :float= margin
	var max_x :float = screen_size.x - margin - zone_size
	
	var min_y :float = margin
	var max_y :float = screen_size.y - margin - zone_size
	
	max_x = max(min_x, max_x)
	max_y = max(min_y, max_y)
	
		# ==========================================
	# NEW: 80% Chance to spawn on the right 1/3rd
	# ==========================================
	var chosen_min_x = min_x
	var chosen_max_x = max_x
	
	# Calculate where the "right 1/3" of our safe area begins
	var safe_width = max_x - min_x
	var right_third_start = min_x + (safe_width * (2.0 / 3.0))
	
	# randf() generates a number from 0.0 to 1.0. 
	# < 0.8 means an 80% chance.
	if randf() < 0.8:
		# 80% Chance: Restrict the spawn area to the Right 1/3rd
		chosen_min_x = right_third_start
		chosen_max_x = max_x
	else:
		# 20% Chance: Restrict the spawn area to the Left 2/3rds
		chosen_min_x = min_x
		chosen_max_x = right_third_start
	# ==========================================
	# Pick a random top-left corner for the zone
	var zone_origin = Vector2(
		randf_range(chosen_min_x, chosen_max_x),
		randf_range(min_y, max_y)
	)

	var indicator_box = ColorRect.new()
	indicator_box.size = Vector2(zone_size, zone_size)
	indicator_box.global_position = zone_origin
	indicator_box.color = Color(1.0, 1.0, 1.0, 0.3) 
	
	add_child(indicator_box)
	
	get_tree().create_timer(3.5).timeout.connect(indicator_box.queue_free)
	await get_tree().create_timer(0.5).timeout
	# ==========================================
	
	# Spawn the enemies inside this newly generated zone
	for i in range(enemy_count):
		var random_offset = Vector2(
			randf_range(0, zone_size),
			randf_range(0, zone_size)
		)
		spawn_queue.append({"res": minion_res, "pos": zone_origin + random_offset})


func _process(_delta):
	if spawn_queue.size() > 0:
		_spawnTimer += _delta
		if _spawnTimer < SPAWN_INTERVAL: return
		_spawnTimer -= SPAWN_INTERVAL  # subtract instead of reset, keeps it accurate
		var data = spawn_queue.pop_front()
		MinionsPool.put_minion_toGame(data.res, data.pos, 0)

		
func _on_timer_timeout():
	spawn_enemies_in_random_zone(44)
