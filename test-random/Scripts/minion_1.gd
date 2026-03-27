extends Area2D
@export var heart_scene: PackedScene
@export var PiercedEffect: PackedScene
@export var deathSound: AudioStreamPlayer2D
@export var AnimatedSprite: AnimatedSprite2D

@export var HP: float
@export var Speed: float
@export var level: int = 1

var Killed: bool = false
var Homing: bool = false
var Player: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#pass
	position.x -= Speed * delta
	if Homing:
		if Player.y <= position.y:
			position.y -= Speed * delta / 2
		else:
			position.y += Speed * delta / 2

func _on_body_entered(body):
	pass
	 # Replace with function body.

func _on_area_entered(area):
	
	if area.is_in_group("bullet") and not Killed:
		spawnPiercedEffect(area.global_position)
		var dmgAmount: int = randf() * 7 + area.baseDmg
		take_damage(dmgAmount)
		HP -= dmgAmount
		#print(HP)
		if HP <= 0:
			Killed = true
			if randf() < 0.5:
				spawnHeart()
			deathSound.play()
			Speed = 0
			var tween = get_tree().create_tween()
			tween.tween_property(self,"modulate", Color.BLACK, 0.13)
			tween.parallel().tween_property(self,"scale",Vector2(1.5,1.5) ,0.13)
			#tween.parallel().tween_property(self,"modulate", Color.TRANSPARENT, 0.3)
			tween.tween_callback(queue_free)
			#await  get_tree().create_timer(0.05).timeout
			#call_deferred("queue_free")	
	
	#if area.is_in_group("bullet"):
		#spawnHeart()
		#call_deferred("queue_free")	
func take_damage(amount: int) -> void:

	# Spawn damage popup
	var random_offset = Vector2(
		randf_range(-18.0, 18.0),
		randf_range(-24.0, 0.0)
	)
	DamageManager.spawnDamage(
		global_position - Vector2(45,55), 
		amount,
		Color.RED,  # Red for enemies/player damage; use Color.CYAN for healing, etc.
		random_offset
	)

		

func spawnHeart():
	
	var heart = heart_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", heart)
	#get_tree().current_scene.add_child(heart)  # Add to main scene
	heart.global_position = global_position

func spawnPiercedEffect(SpawnPosition):
	var Particle = PiercedEffect.instantiate()
	get_tree().current_scene.add_child(Particle)
	Particle.position = SpawnPosition  # Add to main scene
	#bullet.baseDmg += dmg
	## Position bullet at player + muzzle offset
	
	#bullet.global_scale = global_scale * Vector2(scale,scale)


func _on_homing_detect_range_area_entered(area):
	if area.is_in_group("Player"):
		AnimatedSprite.play("Attacking")
		Player = area.global_position
		Homing = true
		Speed += (Speed * 3.25) + (level * 30)
		
		
