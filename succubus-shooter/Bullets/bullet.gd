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
var specific_onDestroyScene: Node2D = null
var _collision: CollisionShape2D

const explosion = preload("res://()Explosion.tscn")

var specific_bulletPoolAmount: int

signal returned_to_pool(this_bullet: Bullet, bullet_name: String)

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
	if SpecificBulletScene.has_signal("bulletHit"):
		SpecificBulletScene.bulletHit.connect(bullet_Hit)
	
	if specific_ability == BulletResource.Ability_list.Exploding:
		specific_onDestroyScene = res.onDestroyScene.instantiate()
		add_child(specific_onDestroyScene)
		pass

func bullet_Hit(touch: Area2D):
	if touch.is_in_group("Enemy"):
		if specific_ability == BulletResource.Ability_list.Piercing:
			return
		else:
			deactivate_bullet()
	if touch.is_in_group("KillZone"):
		deactivate_bullet()



func change_bullet_values(res: BulletResource):
	specific_damage_multiplier = res.damage_multiplier
	specific_speed = res.speed
	

func fire(pos: Vector2, angle: float, Dmg: float) -> void:
	#if is_physics_processing():
		#push_warning("Bullet.fire() called on already-active bullet: %s" % specific_bullet_name)
		#return
	specific_damage = Dmg * specific_damage_multiplier
	global_position = pos
	rotation = deg_to_rad(angle)
	z_index = 3
	_collision.set_deferred("disabled", false)
	show()
	set_process(true)
	set_physics_process(true)
	SpecificBulletScene.set_process(true)
	SpecificBulletScene.set_physics_process(true)
	

func deactivate_bullet() -> void:
	var boom  = explosion.instantiate()
	boom.global_position = global_position
	get_tree().current_scene.add_child(boom)
	hide()
	_collision.set_deferred("disabled", true)
	SpecificBulletScene.set_process(false)
	SpecificBulletScene.set_physics_process(false)
	set_process(false)
	set_physics_process(false)
	returned_to_pool.emit(self, specific_bullet_name)
