extends CharacterBody2D

#region onReady

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite
@onready var body: Area2D = $Area2D
@onready var dmgedTimer: Timer = $damagedTimer
@onready var checkTest: Label = $"../check"
@onready var heatBar: Sprite2D = $"../heatbox/heat"
@onready var shootingSound: AudioStreamPlayer2D = $ShootingSound
@onready var PowerUPSoundPlay: AudioStreamPlayer2D = $PowerUPSound
@onready var GrabHeartSoundPlay: AudioStreamPlayer2D = $GrabHeartSound
#endregion


#region exports

@export var HP: float = 9
@export var PowerLevel: int = 1
@export var Heat: float = 0
@export var maxHeat: float = 40

@export var bullet_scene: PackedScene  # Drag your bullet.tscn here in the inspector!
@export var muzzle_offset: Vector2 = Vector2(72, 12)  # Offset where bullets spawn (right side)
#endregion

signal PowerUpSignal(new_PowerLevel: float)
signal HpChanged(new_HP: float)
signal dead()


var isShooting: bool = false
var damaged: bool = false
var PowerUp: float = 0
var heatTick: float = 0
var last_shot_time: float = 0.0
var fire_cooldown: float = 0.225
var move_speed: float = 700

func _ready(): 
	#nput.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _process(delta):
	var target_pos = get_global_mouse_position()
	var direction = (target_pos - global_position).normalized()
	
	var distance = global_position.distance_to(target_pos)
	if distance > 8.0:
		global_position += direction * move_speed * delta
	else:
		global_position = get_global_mouse_position()
		
	#global_position = global_position.lerp(target_pos, move_speed * delta)	


func _physics_process(delta):
	var current_time = Time.get_ticks_msec() / 1000.0
	#global_position = get_global_mouse_position() #this makes the position of the Ball to immediately be at the mouse position
	checkTest.text = "heat = "+ str(Heat/maxHeat) 
	
	heatBar.scale.x = 0.01 + Heat/maxHeat
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and dmgedTimer.time_left <= 0 :

		#heatTick += 1
		#if heatTick >= 20:
			#heatTick = 0
		if Heat < maxHeat:
			Heat +=  0.05
		if Heat > maxHeat:
			Heat = maxHeat
		
		animated_sprite.play("attacking")
		await get_tree().create_timer(0.03).timeout
		
		if current_time - last_shot_time >= fire_cooldown:
			
			shoot()
			last_shot_time = current_time
	else:
		if Heat > 0:
			Heat -= 0.1
		animated_sprite.play("idle")		
	

func shoot():
	isShooting = true
	if bullet_scene == null:
		push_error("No bullet scene assigned! Create bullet.tscn and drag it here.")
		return
	
	# Spawn bullet
	spawnBullet(0, 0, 1, PowerLevel * 3)
	
	if PowerLevel >= 3:
		await  get_tree().create_timer(0.02).timeout
		spawnBullet(-12,-33,0.55, PowerLevel)
		spawnBullet(-12,33,0.55, PowerLevel)
	
	if PowerLevel >= 6:
		await  get_tree().create_timer(0.04).timeout
		spawnBullet(-40, -64,0.7, PowerLevel * 1.5 )
		spawnBullet(-40, 64,0.7, PowerLevel* 1.5)
		
	if PowerLevel >= 10:
		await  get_tree().create_timer(0.06).timeout
		spawnBullet(-70, -124, 0.4, PowerLevel * 0.8)
		spawnBullet(-70, 124, 0.4, PowerLevel * 0.8)
	
	shootingSound.play()


func spawnBullet(offsetX: float, offsetY: float, scale: float, dmg: float):
	var bullet = bullet_scene.instantiate()
	
	get_tree().current_scene.add_child(bullet)  # Add to main scene
	bullet.baseDmg += dmg
	# Position bullet at player + muzzle offset
	bullet.position = position + Vector2(offsetX,offsetY) +muzzle_offset #+muzzle_offset.rotated(global_rotation)
	bullet.global_scale = global_scale * Vector2(scale,scale)


func _on_area_2d_area_entered(area):
	if area.is_in_group("heart"):
		GrabHeartSoundPlay.play()
		PowerUp += 1
		#print ("PowerUp = "+ str(PowerUp))
		area.queue_free()
		if move_speed < 1000:
			move_speed += 5
		if PowerUp >= 5 :
			
			if fire_cooldown > 0.075 :
				fire_cooldown *= 0.85
			if PowerLevel < 15 :
				PowerUPSoundPlay.play()
				PowerLevel += 1
				emit_signal("PowerUpSignal", PowerLevel)
				
			
			PowerUp = 0
			#print(PowerLevel)
		
	
	if area.is_in_group("enemies") :
		var tween = get_tree().create_tween()
		damaged = true
		dmgedTimer.start()
		tween.tween_property(self,"modulate", Color.BLUE, 0.125)
		tween.parallel().tween_property(self,"position", Vector2(body.global_position.x - 12 , body.global_position. y -12), 0.1)
		tween.tween_property(self,"modulate", Color.BLACK, 0.125)
		tween.parallel().tween_property(self,"position", Vector2(body.global_position.x + 12, body.global_position.y + 12), 0.1)
		tween.tween_property(self,"modulate", Color.WHITE, 0.075)
		HP -= 1
		emit_signal("HpChanged", HP)
		if Heat > 8:
			Heat -= 8
		else:
			Heat = 0
		
		if HP <= 0:
			var deathtween = get_tree().create_tween()
			damaged = true
			dmgedTimer.start()
			deathtween.tween_property(self,"modulate", Color.BLUE, 0.125)
			deathtween.parallel().tween_property(self,"scale", Vector2(2,2), 0.125)
			deathtween.tween_callback(queue_free)
			#queue_free()
	


func _on_power_up_sound_tree_exited():
	emit_signal("dead")
	
