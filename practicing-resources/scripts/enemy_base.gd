#@tool
extends CharacterBody2D

@onready var HpBar := $HPBar/HPLength
@onready var AnimatedSprite:= $AnimatedSprite2D
@onready var AttackTime := $Timer

var current_health: float
var current_max_health: float 
var current_attack_damage: float 
var current_speed: float 
var sprite_frames: SpriteFrames  
var current_Armor: float 
var enemy_name: String
var theSummonWeight: int

enum State {
	IDLE,
	ATTACK,
	HURT,
	DEAD
}

@export var data : EnemyData
signal HPChanged


func _ready():
	if data:
		_load_from_data()
	else:
		push_error("Enemy has no EnemyData assigned!")


func attacking():
	AnimatedSprite.play(data.attack_anim)
	pass

func death():
	AnimatedSprite.play(data.death_anim)



func _on_animated_sprite_2d_animation_finished():
	if AnimatedSprite.animation == data.attack_anim:
		AnimatedSprite.play(data.idle_anim)
		AttackTime.paused = false
	elif AnimatedSprite.animation == data.death_anim:
		$CollisionShape2D.set_deferred("disabled", true)
		call_deferred("queue_free")
		


func _on_timer_timeout():
	if current_health <= 0:
		return
	attacking()
	AttackTime.paused = true


func _load_from_data():
	enemy_name = data.enemy_name
	current_health = data.max_health
	current_max_health = data.max_health
	theSummonWeight = data.SummonWeight
	# Load the SpriteFrames from the resource
	AnimatedSprite.sprite_frames = data.sprite_frames
	AnimatedSprite.play(data.idle_anim)
	add_to_group("enemies")


func takeAttack(amount: float):
	if Engine.is_editor_hint():
		return 
	HPChanged.emit()
	var randomDmg = randf_range(-6.0, 12.0)
	var actual_damage = maxf(amount - current_Armor + randomDmg, 0.0)
	current_health = clampf(current_health - actual_damage, 0.0, current_max_health)
	HpBar.updateBar(current_health, current_max_health)
	if current_health <= 0.0:
		death()




func _on_property_list_changed():
	_load_from_data()
	pass # Replace with function body.
