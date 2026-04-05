class_name Bullet
extends Node2D

var SpecificBulletScene: Area2D # holds the actual bullet scene, its area2D 

#base values of bullet:
var specific_bullet_name: String
var specific_damage_multiplier: float
var specific_damage: float

var Playerbonusdamage: float
var specific_speed: float
var specific_angle: float
var specific_ability: BulletResource.Ability_list 
var specific_onDestroyScene: Node2D 
var _collision: CollisionShape2D

# below are for bullet abiliets values
var specific_pierceCount: int
var specific_maxPierceCount : int

var specific_lifestealChance: float
var specific_lifestealAmount: float

var specific_weakPiercingDmgDropoff: float



var specific_bulletPoolAmount: int

signal returned_to_pool(this_bullet: Bullet, bullet_name: String)
signal lifesteal(amount: float)

func _physics_process(delta):
	position += transform.x * specific_speed * delta 


func load_from_resource(res: BulletResource):
	SpecificBulletScene = res.SpecificBulletScene.instantiate()
	add_child(SpecificBulletScene)
	specific_bullet_name = res.bullet_name
	specific_bulletPoolAmount = res.bulletPoolAmount
	specific_damage_multiplier = res.damage_multiplier
	specific_speed = res.speed
	specific_ability = res.ability
	_collision = SpecificBulletScene.find_child("CollisionShape2D")
	_collision.disabled = true
	specific_onDestroyScene = res.onDestroyScene.instantiate()
	add_child(specific_onDestroyScene)
	SpecificBulletScene.bulletHit.connect(bullet_Hit)
	
	# Below for Skill-specific Stuff :
#region skill-specific stat stat filling
	specific_maxPierceCount = res.weakPiercing_maxPierceCount
	
	specific_lifestealChance = res.lifesteal_chance
	specific_lifestealAmount = res.lifesteal_heal
	
	specific_weakPiercingDmgDropoff = res.weakPiercing_DmgDropoffPercent
#endregion
	
	

func bullet_Hit(touch: Area2D):
	if touch.is_in_group("Enemy"):
		match specific_ability:
			BulletResource.Ability_list.None:
				deactivate_bullet()
				
			BulletResource.Ability_list.Piercing: 
				if specific_pierceCount < 1 :
					spawnExplosion(touch.global_position)
					specific_pierceCount += 1
				return  # this means bullet wont get deleted upon tousching enemies
				
			BulletResource.Ability_list.WeakPiercing:
				if specific_pierceCount < 1 :
					spawnExplosion(touch.global_position)
					
				if specific_pierceCount >= specific_maxPierceCount:
					deactivate_bullet()
				else:
					specific_damage = specific_damage * ((100.0 - specific_weakPiercingDmgDropoff)/100)
					modulate.a *=  ((100.0 - specific_weakPiercingDmgDropoff)/100)
				specific_pierceCount += 1
			
			BulletResource.Ability_list.Lifesteal:
				if randf() * 100 <= specific_lifestealChance:
					lifesteal.emit(specific_lifestealAmount)
					deactivate_bullet()


	if touch.is_in_group("KillZone"):
		deactivate_bullet()


func spawnExplosion(pos : Vector2):
	var explosion = specific_onDestroyScene.duplicate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = pos
	explosion.isCopy = true
	explosion.activate()


func change_bullet_values(res: BulletResource):
	specific_damage_multiplier = res.damage_multiplier
	specific_speed = res.speed

func fire(pos: Vector2, angle: float, Dmg: float) -> void:

	modulate.a = 1
	specific_damage = Dmg * specific_damage_multiplier
	specific_pierceCount = 0
	global_position = pos
	rotation = deg_to_rad(angle)
	z_index = 3
	_collision.set_deferred("disabled", false)
	SpecificBulletScene.show()
	set_process(true)
	set_physics_process(true)
	SpecificBulletScene.set_process(true)
	SpecificBulletScene.set_physics_process(true)
	

func deactivate_bullet() -> void:
	if specific_ability != BulletResource.Ability_list.WeakPiercing and specific_ability != BulletResource.Ability_list.Piercing:
		specific_onDestroyScene.activate()
	
	SpecificBulletScene.hide()
	_collision.set_deferred("disabled", true)
	SpecificBulletScene.set_process(false)
	SpecificBulletScene.set_physics_process(false)
	set_process(false)
	set_physics_process(false)
	returned_to_pool.emit(self,specific_bullet_name)
