class_name bullet_pool
extends Node

var POOL_SIZE: int =0

#var pool_ofBullets : Array [Bullet] =[]
var bullet_dictionary: Dictionary = {}

var blank_bullet : PackedScene = preload("res://Bullets/bullet.tscn")

var Player: PlayerCharacter

func _ready():
	await get_tree().process_frame
	getPlayerData()

func getPlayerData():
	Player = get_tree().get_nodes_in_group("thePlayer")[0]
	if Player:
		#Player.UpgradeBullet.connect(UpgradeBullets)
		for bullets_res in Player.bullet_resources:
			if bullets_res:
				fill_bullets_pool(bullets_res)


func modify_bullets(bullet_name: String, modifier: Callable):
	if bullet_dictionary.has(bullet_name):
		for bullet in bullet_dictionary[bullet_name]:
			modifier.call(bullet)


func fill_bullets_pool(bullet_resource: BulletResource):
	var dictionary_bullet_name = bullet_resource.bullet_name
	bullet_dictionary[dictionary_bullet_name] = []
	for bullet_amount in bullet_resource.bulletPoolAmount:	
		var this_bullet :Bullet = blank_bullet.instantiate()
		add_child(this_bullet)
		this_bullet.returned_to_pool.connect(return_to_pool)
		this_bullet.set_process(false)
		this_bullet.set_physics_process(false)
		#this_bullet.visible = false
		this_bullet.global_position = Vector2(-256,-256)
		this_bullet.load_from_resource(bullet_resource)
		bullet_dictionary[dictionary_bullet_name].append(this_bullet)


func get_bullet_fromPool(bulletName: String) -> Bullet:
	if  bullet_dictionary.has(bulletName):
		return bullet_dictionary[bulletName].pop_front()
	else:
		return null


func put_bullet_toGame(bulletName: String, spawn_position: Vector2, bullet_rotation_degree : float, Dmg: float, on_fire: Callable = Callable()):
	var bullet = get_bullet_fromPool(bulletName)
	if bullet:
		if on_fire.is_valid():
			on_fire.call(bullet)
		bullet.fire(spawn_position, bullet_rotation_degree, Dmg)
		


func return_to_pool(bullet :Bullet, bullet_name: String):
	if bullet not in bullet_dictionary[bullet_name]:
		bullet_dictionary[bullet_name].push_back(bullet)
	
