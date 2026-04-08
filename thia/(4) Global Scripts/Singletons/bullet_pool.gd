# bullet_pool.gd
extends Node

const bullet_pool_pos: Vector2 = Vector2(-128,-128)
#var bullets: Array [Bullet]
var bullet_Dict: Dictionary
var bullet_Eff_Dict: Dictionary

var onBulletDestroyEff_Dict : Dictionary

var Player: PlayerCharacter

@onready var blank_bullet : PackedScene = preload("res://(1) Player/bullets/blank_bullet.tscn")

# below is WIP
#@onready var basic_explosion: Array[PackedScene] = preload()    
#@onready var piercing_explosion: Array[PackedScene] = preload()
#@onready var Huge_explosion: Array[PackedScene] = preload()

func _ready():
	await get_tree().process_frame
	Player = get_tree().get_first_node_in_group("thePlayer")
	if Player:
		for Cur_bRes in Player.Cur_bullets_res:
			build_pool(Cur_bRes)
	
	
func build_pool(_theBulletRes: Bullet_Res):
	var b_name: String = _theBulletRes.bullet_name
	bullet_Dict[b_name] = []
	#bullet_Eff_Dict[b_name] = []
	for count in range(_theBulletRes.amount_InPool):
		var newBullet : Bullet = blank_bullet.instantiate()
		add_child(newBullet)
		newBullet.z_index = ZIndex_constants.BULLETS
		newBullet.global_position = bullet_pool_pos
		newBullet.visible = false
		newBullet.process_mode = Node.PROCESS_MODE_DISABLED
		newBullet.bullet_returned_toPool.connect(return_to_pool)
		#  bullet pool is different from enemy pool in bullet pool, data
		#  is loaded firsthand, then stored as a specific bullet unlike in 
		#  enemy pool where they are stored as blanks first, loaded with data when summoned
		newBullet.load_data_from_res(_theBulletRes)   
		  
		
		bullet_Dict[b_name].append(newBullet)


func get_bullet_fromPool(_bullet_name: String) -> Bullet:
	if  bullet_Dict.has(_bullet_name):
		return bullet_Dict[_bullet_name].pop_back()
	else:
		return null


func put_bullet_toGame(_bullet_name: String, _playerStr: float , _spawnPos: Vector2, 
						_MoveFunc: Callable = Callable(), _onSpawnFunc: Callable = Callable()) :
	var theBullet: Bullet = get_bullet_fromPool(_bullet_name)
	if theBullet:
		theBullet.global_position = _spawnPos
		theBullet.process_mode = Node.PROCESS_MODE_INHERIT
		theBullet.activate(_playerStr, _MoveFunc, _onSpawnFunc)
		
func put_onDestroy_eff_toGame(_onDestroy_name: String):
	pass


func return_to_pool(_bullet: Bullet):
	_bullet.global_position = bullet_pool_pos
	_bullet.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
	#_bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet_Dict[_bullet.bullet_name].append(_bullet)



	
