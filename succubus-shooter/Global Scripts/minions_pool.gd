class_name minion_pool
extends Node

const minion_POOL_SIZE: int = 500


#var pool_ofBullets : Array [Bullet] =[]
var OngoingMinion_pool: Array[basic_minion] = []

var blank_minion : PackedScene = preload("res://Minions/Blank_Minions.tscn")

var Player: PlayerCharacter
var deepDif: int

func _ready():
	await get_tree().process_frame
	getGameData()
	fill_minions_pool()

func getGameData():
	deepDif = GameLevelManager.Deep_Difficulty
	Player = get_tree().get_nodes_in_group("thePlayer")[0]
	if Player:
		pass

func fill_minions_pool():

	for minion_amount in minion_POOL_SIZE:
		var this_minion : basic_minion = blank_minion.instantiate()
		add_child(this_minion)
		this_minion.returned_minion_to_pool.connect(return_minion_to_pool)
		this_minion.set_process(false)
		this_minion.visible = false
		this_minion.position = Vector2(1256,-256)
		OngoingMinion_pool.append(this_minion)
	

func get_minion_fromPool(res: MinionResource) -> basic_minion:
	if  OngoingMinion_pool.size() > 0:
		var specific_minion = OngoingMinion_pool.pop_front()
		#await get_tree().process_frame
		specific_minion.load_miniondata_from_resource(res)
		return specific_minion
	else:
		return null

	
func put_minion_toGame(res: MinionResource, spawn_position: Vector2, onSpawn: Callable = Callable(), minion_movementOverride : Callable = Callable() ):
	
	#var minion = await get_minion_fromPool(res)
	var minion = get_minion_fromPool(res)
	if minion:
		minion.spawn(spawn_position, minion_movementOverride, onSpawn)


func return_minion_to_pool(minion: Node):
	OngoingMinion_pool.append(minion)
