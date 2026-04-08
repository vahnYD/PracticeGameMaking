
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
	seek_spawners(self)

func seek_spawners(_node: Node):
	for child in _node.get_children():
		if child is EnemySpawnerBox:
			child.get_enemy_data.connect(send_enemy_data)
			child.slide_speed = spawner_slide_speed
			child.start_game()
			child.homingTarget = Player
			spawner_list.append(child)
		else:
			seek_spawners(child)
	
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
	
func send_enemy_data(_spawner: EnemySpawnerBox, _enemy_name: String, _onSpawnFunc: Callable = Callable(),
 _move_override: Callable = Callable(), _move_overrideDur: float = 0.0 , _override_VeerStr : float = 0.0) :
	
	var source: EnemyScaledData = enemy_dict[_enemy_name]
	var data := EnemyScaledData.new()
	
	# Copy all base stats from the dict
	data.enemy_name = source.enemy_name
	data.HP = source.HP
	data.ATK = source.ATK
	data.DEF = source.DEF
	data.move_spd = source.move_spd
	data.move_type = source.move_type
	data.is_special = source.is_special
	data.sprite = source.sprite
	data.collision_shape = source.collision_shape
	data.player_target = source.player_target
	data.enemy_rarity = source.enemy_rarity
	
	# Then apply spawner-specific overrides
	data.onSpawnFunc = _onSpawnFunc
	data.move_Override = _move_override
	data.move_overrideDur = _move_overrideDur
	data.override_VeerStr = _override_VeerStr
	
	_spawner.cur_enemy_data = data
	_spawner.activate_spawner()
	
