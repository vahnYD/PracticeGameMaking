# enemy_pool.gd
extends Node

const enemy_count: int = 500
const enemy_pool_pos: Vector2 = Vector2(512,-128)
var blank_enemies: Array [Enemy]
@onready var blank_enemy: PackedScene = preload("res://(2)Enemies/enemy_blank.tscn")

func _ready():
	await get_tree().process_frame
	build_pool()
	
func build_pool():
	for count in range(enemy_count):
		var newblank : Enemy = blank_enemy.instantiate()
		add_child(newblank)
		newblank.visible = false
		newblank.set_process(false)
		newblank.set_physics_process(false)
		newblank.returnedToPool.connect(return_to_pool)
		newblank.z_index = ZIndex_constants.ENEMIES
		newblank.global_position = enemy_pool_pos
		blank_enemies.append(newblank)

func return_to_pool(_enemy: Enemy):
	_enemy.global_position = enemy_pool_pos
	blank_enemies.append(_enemy)


func put_enemy_toGame(_enemy_dict: EnemyScaledData, _spawnPos: Vector2) :
	var newEnemy: Enemy = blank_enemies.pop_back()
	if newEnemy:
		newEnemy.load_data(_enemy_dict)
		newEnemy.global_position = _spawnPos

	
	
	
	
