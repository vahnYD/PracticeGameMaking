class_name enemy_pool_manager
extends Node

@onready var enemy: PackedScene = preload("res://enemies/minions/blank_enemy.tscn")
var blank_enemies : Array[Enemy] = []

func build_pool():
	for i in 100:
		var curEnemy : Enemy = enemy.instantiate()
		add_child(curEnemy)
		curEnemy.name = "blankEnemyNo" + str(i)
		curEnemy.visible = false
		curEnemy.set_process(false)
		curEnemy.set_physics_process(false)
		curEnemy.death.connect(put_enemy_toPool)
		blank_enemies.append(curEnemy)

func put_enemy_to_scene(_Enemy_dictionary: ScaledEnemyData, spawnPos: Vector2) :
	var CurEnemy : Enemy = blank_enemies.pop_back()
	if CurEnemy:
		CurEnemy.load_data(_Enemy_dictionary)
		CurEnemy.name = "filledEnemy"
		CurEnemy.global_position = spawnPos
		CurEnemy.visible = true
		CurEnemy.set_process(true)
		CurEnemy.set_physics_process(true)
		CurEnemy.on_spawn()
		
func put_enemy_toPool(enemy: Enemy):
		enemy.visible = true
		enemy.set_process(true)
		enemy.set_physics_process(true)
		blank_enemies.append(enemy)
