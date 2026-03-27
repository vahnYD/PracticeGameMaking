class_name EnemySpawner
extends Node2D
@onready var spawnTime: Timer = $SpawnTimeTimer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@export var enemy_scenes: Array[PackedScene] # Drag your enemy .tscn files here in the inspector 
											# AFTER THIS IS PLACED ON A GAME LEVEL
@export var wall_collision_layer: int = 1 # Make sure your map walls are on Layer 1
@export var SpawnRange: float = 60 # default is 60, as the size of basic spawner circle
@export var maxSummonAttempt: int = 120 # default summon attempt
@export var SpawnCount: int = 10 # first level spawn count
@export var newWaitTime: float 
@export var TheMainCrystal: Area2D
@export var thisSpawnerWeightMultiplier: float = 1


var currentTimeSpawnMultiplier: float = 3
var levelSpawnBase: int = 7
var global_difficulty: int

var maxSpawnWeight: int
var curSpawnWeight: int

func _ready():
	spawnTime.wait_time = newWaitTime
	spawnTime.start(newWaitTime)
	global_difficulty = get_tree().current_scene._LevelDifficulty
	difficulty_change()

func difficulty_change():
	maxSpawnWeight = (int(global_difficulty * currentTimeSpawnMultiplier * thisSpawnerWeightMultiplier) + levelSpawnBase)

func spawn_batch():
	var spawned_count = 0
	var attempts = 0
	var space_state = get_world_2d().direct_space_state

	# Try to spawn 10 enemies, give up after 120 attempts to prevent infinite loops if the map is full
	while spawned_count < SpawnCount and attempts < maxSummonAttempt:
		attempts += 1
		
		# Random position within radius of 60
		var angle = randf() * TAU
		var distance = randf() * SpawnRange * 1.25 # 1.25 to allow outside spawnCircle's spawning, but not too far
		var spawn_pos = global_position + Vector2(cos(angle), sin(angle)) * distance
		
		# Check if the spawn position hits a wall
		var MinionQuery = PhysicsShapeQueryParameters2D.new()
		var MinionShape = RectangleShape2D.new()
		MinionShape.size = Vector2(50, 50) # Enemy max size
		
		MinionQuery.shape = MinionShape
		MinionQuery.transform = Transform2D(0, spawn_pos)
		MinionQuery.collision_mask = wall_collision_layer 
		
		var collisions = space_state.intersect_shape(MinionQuery)
		
		if collisions.is_empty():
			# No collision! Safe to spawn.
			var random_enemy = enemy_scenes.pick_random()
			var enemy_instance = random_enemy.instantiate()
			enemy_instance.global_position = spawn_pos
			if curSpawnWeight <= maxSpawnWeight - enemy_instance.get_meta("difficulty"): 
				#print("difficulty meta: " + str(enemy_instance.get_meta("difficulty")) + "|| enemy.difficulty : " + str(enemy_instance.difficulty)) 
				#print((int(global_difficulty * currentTimeSpawnMultiplier * thisSpawnerWeightMultiplier) + levelSpawnBase))
				await get_tree().create_timer(0.1 * spawned_count).timeout
				get_parent().add_child(enemy_instance)
				spawned_count += 1
				curSpawnWeight += enemy_instance.get_meta("difficulty")
				
	print("Spawned " + str(spawned_count) + "enemies; Total Weight of: " + str(curSpawnWeight))
	curSpawnWeight = 0


func _on_timer_timeout():
	var valid_position = find_empty_spot()
	
	# Vector2.INF is our custom flag that means "we failed to find a spot"
	if valid_position != Vector2.INF:
		position = valid_position
		call_deferred("spawn_batch")
		
	else:
		print("can't find valid position")
	

func find_empty_spot() -> Vector2:
	# 1. Get direct access to Godot's physics engine in the current world
	var space_state = get_world_2d().direct_space_state
	
	
	# 3. Get the camera/screen bounds so we spawn within the screen
	# If you have a moving camera, this gets the current visible area
	var camera = get_viewport().get_camera_2d()
	var screen_center = camera.global_position if camera else get_viewport_rect().get_center()
	var screen_size = get_viewport_rect().size
	var screenOffset: float = 64
	var min_x = screen_center.x - ((screen_size.x / 2.0) - screenOffset)
	var max_x = screen_center.x + ((screen_size.x / 2.0) - screenOffset)
	var min_y = screen_center.y - ((screen_size.y / 2.0) - screenOffset)
	var max_y = screen_center.y + ((screen_size.y / 2.0) - screenOffset)
	
		# 4. Try to find a spot multiple times
	for SpotPickAttempts in range(40):
		# Pick a random coordinate on the screen
		var random_pos = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		
		# Prepare the Physics Query (The question we ask the engine)
		var SpawnerQuery = PhysicsShapeQueryParameters2D.new()
		var SpawnerShape = RectangleShape2D.new()
		SpawnerShape.size = Vector2(90, 90)
		SpawnerQuery.shape = SpawnerShape
		SpawnerQuery.transform = Transform2D(0, random_pos)  # Place the ghost shape at the random position
		SpawnerQuery.collision_mask = wall_collision_layer   # ONLY check against Layer 1 (Walls/Trees)
		
		# 5. Ask the physics engine if the ghost shape touches anything
		var overlaps = space_state.intersect_shape(SpawnerQuery)
		
		# If the overlaps array is empty, it means the spot is completely free!
		if overlaps.is_empty() and random_pos.distance_to(TheMainCrystal.global_position) > 200 :
			animationPlayer.play("new_animation")
			return random_pos
			
	return Vector2.INF
