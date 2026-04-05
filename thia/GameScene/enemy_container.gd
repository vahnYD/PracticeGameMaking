
class_name EnemyContainer
extends Node

var enemy_dict : Dictionary
var spawner_list : Array[EnemySpawnerBox]
var ongoingDif : float

var HP_mult: float = 1.0
var ATK_mult: float = 0.2
var DEF_mult: float = 0.1

var spawner_slide_speed: float
var Player: PlayerCharacter

func _ready():
	await get_tree().process_frame
	call_deferred("grab_spawners")


func grab_spawners():
	for enemy_spawner in get_children():
		if enemy_spawner is EnemySpawnerBox:
			enemy_spawner.get_enemy_data.connect(send_enemy_data)
			enemy_spawner.slide_speed = spawner_slide_speed
			enemy_spawner.gameStart = true
			enemy_spawner.homingTarget = Player
			spawner_list.append(enemy_spawner)

	
func build_curLevel_dict(_enemy_list: Array[EnemyResources], _level_Dif: float):
	for e:EnemyResources in _enemy_list:
		var enemy_data:= EnemyScaledData.new()
		enemy_data.enemy_name = e.enemy_name
		enemy_data.HP = e.HP + (_level_Dif * 1)
		enemy_data.ATK = e.ATK + (_level_Dif * 0.65)
		enemy_data.DEF = e.DEF + (_level_Dif * 0.35)
		enemy_data.move_spd = e.move_spd
		enemy_data.move_type = e.move_type
		enemy_data.sprite = e.sprite
		enemy_data.collision_shape = e.collision_shape
		enemy_data.player_target = get_tree().get_first_node_in_group("thePlayer")
		enemy_dict[e.enemy_name] = enemy_data
	
func upgrade_dict(_enemy_name: String, _newStats: EnemyScaledData):	
	enemy_dict[_enemy_name] = _newStats
	
func send_enemy_data(_spawner: EnemySpawnerBox, _enemy_name: String, _move_override: Callable = Callable(), _move_overrideDur: float = 0.0) :
	var data:= EnemyScaledData.new()
	data = enemy_dict[_enemy_name]
	data.move_Override = _move_override
	data.move_overrideDur = _move_overrideDur
	_spawner.cur_enemy_data = data
	_spawner.activate_spawner()
	
#func spawn_enemies_basic(_enemy_name: String, _amount: int, _interval: float, _curve_name: String, _spawn_pos: Vector2):
	#var activeSpawner : EnemySpawnerBox = spawner_list.pop_back()
	#activeSpawner.global_position = _spawn_pos
	#activeSpawner.activate_spawner(_curve_name)
	#for i in range(_amount):
		#await get_tree().create_timer(_interval).timeout
		#EnemyPool.put_enemy_toGame(enemy_dict[_enemy_name],activeSpawner.enemy_spawnPos)
	
