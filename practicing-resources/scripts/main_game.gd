extends Node2D

var basicEnemies := []
#var currentEnemy: PackedScene
@export var EnemyResources: Array[EnemyData]
@export var BlankEnemy: PackedScene
@export var MaxSummonWeight: int
@export var CurrentSummonWeight: int

func _ready():
	var screen_size : Vector2 = get_viewport_rect().size
	var loop_counter : int = 0
	while CurrentSummonWeight <= MaxSummonWeight and loop_counter < 100:
		var random_position: Vector2 = get_random_screen_coordinate(screen_size)
		#var currentEnemy = EnemyResources.pick_random()
		var currentEnemy = EnemyResources.filter(func(filtered_enemy: EnemyData) -> EnemyData:
		# Rule A: The enemy must not exceed the remaining level budget
			if filtered_enemy.SummonWeight <= MaxSummonWeight - CurrentSummonWeight:
				return filtered_enemy
			else:
				return
		)
		if currentEnemy.size() > 0:
			var enemy = BlankEnemy.instantiate()
			var success: bool = false
			if randf() < 0.80:
				for e in currentEnemy:
					if e.SummonWeight <= 2.0:
						enemy.data = e
						success = true
			else:
				for e in currentEnemy:
					if e.SummonWeight >= 2.0:
						enemy.data = e
						success = true
			#the code above is very shit and should be replaced, once enemies are added, the code completely breaks
			
			
			
			#enemy.data = currentEnemy.pick_random()
			if success:
				CurrentSummonWeight += enemy.data.SummonWeight
				await get_tree().create_timer(0.03 * loop_counter).timeout
				
				add_child(enemy)
				enemy._load_from_data() #replaces the data after a blank enemy is spawned.
				enemy.position = random_position
			
			
		else:
			break 
		#print("MaxSummonWeight - CurrentSummonWeight = " + str(MaxSummonWeight - CurrentSummonWeight))
		#print ("CurrentSummonWeight : " + str(CurrentSummonWeight))
		loop_counter += 1

	basicEnemies = get_tree().get_nodes_in_group("enemies")



	

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			for enemy in basicEnemies:
				if is_instance_valid(enemy):
					enemy.takeAttack(10)
				pass
	elif event is InputEventMouseMotion:
		# Use event.relative for captured mode for delta movement
		# Use event.position for visible mode for screen coordinates
		pass
func _spawnEnemies():
	
	pass

func get_random_screen_coordinate(screen_size: Vector2) -> Vector2:
	# Instantiate a RandomNumberGenerator
	var rng = RandomNumberGenerator.new()
	#rng.seed = Time.get_unix_time_from_system()
	# Get a random integer for the X coordinate between 0 and the screen width
	var rand_x: int = rng.randi_range(round(screen_size.x * 0.1), round(screen_size.x * 0.9))
	
	# Get a random integer for the Y coordinate between 0 and the screen height
	var rand_y: int = rng.randi_range(round(screen_size.y  * 0.1), round(screen_size.y  * 0.9))
	
	# Return the new Vector2 coordinate
	return Vector2(rand_x, rand_y)
