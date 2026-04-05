class_name gameplay_manager
extends Node
@onready var initAtkSpot: Sprite2D = $"../initAtkSpot"
@onready var EnemyPool : enemy_pool_manager = $EnemyPool
var EnemySpawnSpots: Array[Vector2]

var _cur_enemyResDict: Dictionary = {}

var game_On: bool = false
var screenSize : Vector2
var curScore: int
var curTime: int
var spawnBugdet: float = 1000.0
var curDifficulty: float = 1.0
@onready var spawnTimer: Timer = $spawnTimer
@onready var minuteTimer: Timer = $minuteTimer


func _ready():
	game_On = true
	pos_init()
	EnemyPool.build_pool()
	var _curLevel_enemy_resources : Array[enemy_resources] = get_tree().current_scene.curLevel_enemy_resources
	for enemy in _curLevel_enemy_resources:
		var scaled_enemy_data := ScaledEnemyData.new()
		scaled_enemy_data.res = enemy
		scaled_enemy_data.enemy_name = enemy.enemy_name
		scaled_enemy_data.sprite_frames = enemy.sprite_frames
		scaled_enemy_data.hp = enemy.HP * curDifficulty
		scaled_enemy_data.atk = enemy.ATK + (enemy.ATK * curDifficulty * 0.5)
		scaled_enemy_data.def = enemy.DEF + curDifficulty * 0.5
		scaled_enemy_data.atk_speed = enemy.atk_speed + (enemy.atk_speed * curDifficulty * 0.35)
		scaled_enemy_data.isSpecial = 0.0
		scaled_enemy_data.rarity = 0.0
		scaled_enemy_data.mov_speed = enemy.mov_speed
		scaled_enemy_data.collision_radius = enemy.collisionRadius
		scaled_enemy_data.spawn_weight = enemy.spawn_weight
		_cur_enemyResDict[enemy.enemy_name] = scaled_enemy_data

func _process(delta):
	pass
	
func pos_init():
	initAtkSpot.visible = false
	var SpawnHelpers = get_tree().get_nodes_in_group("spawnSpot")
	for SpawnHelper in SpawnHelpers:
		SpawnHelper.visible = false
		EnemySpawnSpots.append(SpawnHelper.global_position)
	screenSize = get_viewport().size
	var flip : int = 1
	var radius : float = 128.0
	for i in 7:
		var count: float = floorf((float(i) + 1)/2)
		var newSpot = Marker2D.new()
		newSpot.name = "enemyAtkSpot" + str(i)
		newSpot.add_to_group("enemyAtkSpot")
		
		add_child.call_deferred(newSpot)
		newSpot.global_position.y = initAtkSpot.global_position.y
		newSpot.global_position.x = initAtkSpot.global_position.x + radius * count * flip
		flip *= -1
		

func initWave():
	pass
	
func spawn_enemyRandom(_amount: int, _difficulty: int):
	var _affordableEnemies := _cur_enemyResDict.values().filter(func(res): 
		return res.spawn_weight >= float(_difficulty) * curDifficulty and res.spawn_weight <= spawnBugdet)
	if _affordableEnemies.size() > 0:
		var total_rarity_weight: float = 0.0

		for enemy: ScaledEnemyData in _affordableEnemies:
			
			enemy.rarity = 1.0/ enemy.spawn_weight
			total_rarity_weight += enemy.rarity
			if randf_range(0,200.0) < curDifficulty * float(_difficulty):
				enemy.isSpecial = 1.5
		
		for i in _amount:
			await get_tree().create_timer(0.2222 + randf()).timeout
			spawn_enemy(total_rarity_weight, _affordableEnemies)
		

func spawn_enemy(total_rarity_weight : float, _affordableEnemies: Array):
	var randomValue: float = randf_range(0.0, total_rarity_weight)
	var selected_enemy: ScaledEnemyData = null
	var count : int = 0
	# --- THE SELECTION MATH ---
	for enemy: ScaledEnemyData in _affordableEnemies:
		randomValue -= enemy.rarity
		count +=1
		if randomValue <= 0.0 and spawnBugdet >=  enemy.spawn_weight:
			selected_enemy = enemy
			spawnBugdet -= enemy.spawn_weight
			EnemyPool.put_enemy_to_scene(selected_enemy,EnemySpawnSpots.pick_random())
			break # We found our enemy, exit this inner loop!
	
	
func _on_minute_timer_timeout():
	curTime += 1


func _on_spawn_timer_timeout():
	pass # Replace with function body.
