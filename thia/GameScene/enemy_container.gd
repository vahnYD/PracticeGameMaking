
class_name EnemyContainer
extends Node

var enemy_dict : Dictionary
var spawner_list : Array[EnemySpawnerBox]
var spawner_group_list : Array[Spawner_Group]
var onGoingDif : float
var levelDif: float

var HP_mult: float = 1.0
var ATK_mult: float = 0.2
var DEF_mult: float = 0.1

var current_time_offset: float = 0.0

var spawner_slide_speed: float
var Player: PlayerCharacter

func _ready():
	await get_tree().process_frame
	call_deferred("setup_spawners")


func setup_spawners():
	seek_spawners(self)
	await get_tree().process_frame
	spawner_group_list.sort_custom(func(a, b): return a.queue_no < b.queue_no)	
	var time_offset: float = 0.0
	for group : Spawner_Group in spawner_group_list:
		group.activate_time = time_offset
		group.update_spawners(spawner_slide_speed)
		time_offset += group.duration
		
		
func seek_spawners(_node: Node):
	for child in _node.get_children():
		if child is EnemySpawnerBox:
			child.get_enemy_data.connect(send_enemy_data)
			child.slide_speed = spawner_slide_speed
			child.homingTarget = Player
			spawner_list.append(child)
		elif child is Spawner_Group:
			spawner_group_list.append(child)
			child.visible = true
			child.UpgradeOnGoingDif.connect(upgradeOngoingDif)
			seek_spawners(child)

## building base enemies for the current level.
## their strength increased by the level's difficulty
func build_curLevel_dict(_enemy_list: Array[EnemyResources], _level_Dif: float):
	levelDif = _level_Dif
	for e:EnemyResources in _enemy_list:
		var enemy_data:= EnemyScaledData.new()
		enemy_data.enemy_name = e.enemy_name
		enemy_data.HP = e.HP + (_level_Dif * 25)
		enemy_data.ATK = e.ATK + (_level_Dif * 0.65) 
		enemy_data.DEF = e.DEF + (_level_Dif * 0.1)
		enemy_data.onGoingDiff = e.base_difficulty + ( _level_Dif * 2.0 )
		enemy_data.move_spd = e.move_spd
		enemy_data.move_type = e.move_type
		enemy_data.sprite = e.sprite
		enemy_data.collision_shape = e.collision_shape
		enemy_data.player_target = get_tree().get_first_node_in_group("thePlayer")
		enemy_dict[e.enemy_name] = enemy_data
	
# its probably better to scale enemies at once on send_enemy_data
#func upgrade_dict(_enemy_name: String, _newStats: EnemyScaledData):	
	#enemy_dict[_enemy_name] = _newStats

func upgradeOngoingDif(_value : float):
	onGoingDif = levelDif + _value

## send enemy data while also applying their further, final scaling.
## currently, only HP is affected.
func send_enemy_data(_spawner: EnemySpawnerBox, _enemy_name: String, _onSpawnFunc: Callable = Callable(),
 _move_override: Callable = Callable(), _move_overrideDur: float = 0.0 , _override_VeerStr : float = 0.0) :
	var source: EnemyScaledData = enemy_dict[_enemy_name]
	var data := EnemyScaledData.new()
	
	# Copy all base stats from the dict
	# apply scaling, if any
	data.enemy_name = source.enemy_name
	data.HP = source.HP * pow(onGoingDif, 1.05)
	data.ATK = source.ATK + onGoingDif * 1.2
	data.DEF = source.DEF + onGoingDif * 0.2
	data.move_spd = source.move_spd
	data.move_type = source.move_type
	data.is_special = source.is_special
	data.sprite = source.sprite
	data.collision_shape = source.collision_shape
	data.player_target = source.player_target
	data.enemy_rarity = source.enemy_rarity
	data.onGoingDiff = source.onGoingDiff + onGoingDif
	
	# Then apply spawner-specific overrides
	data.onSpawnFunc = _onSpawnFunc
	data.move_Override = _move_override
	data.move_overrideDur = _move_overrideDur
	data.override_VeerStr = _override_VeerStr
	
	_spawner.cur_enemy_data = data
	_spawner.activate_spawner()
	
