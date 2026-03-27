extends Area2D

@export var speed: float = 230.0  # Tweak in Inspector!
@export var top_bound: float = 200.0   # Top of screen (pixels from top)
@export var bottom_bound: float = 700.0  # Bottom patrol limit (from top)
@export var HP: float 
@export var tookDmg: float
var Dark: float

var moving_up: bool = true
@onready var screen_size: Vector2 = get_viewport_rect().size
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Move RIGHT (side-scroller style)
	# Auto-destroy off-screen
	#var movingUP = true 
	#if position.y > get_viewport_rect().size.y -900 and movingUP == true:
		#position += Vector2.UP * 500 * delta
	#else:
		#position += Vector2.DOWN * 500 * delta
		
	if moving_up and position.y <= top_bound:
		moving_up = false
	elif not moving_up and position.y >= bottom_bound:
		moving_up = true
	
	# STEP 2: Move based on direction
	if moving_up:
		position += Vector2.UP * speed * delta  # UP = decrease Y
	else:
		position += Vector2.DOWN * speed * delta  # DOWN = increase Y
		

#func _on_body_entered(body):
	#if HP <= 0:
		#queue_free()
	#pass # Replace with function body.
	
func take_damage(amount: int) -> void:
	# Your damage logic here, e.g.:
	# health -= amount
	# if health <= 0: die()
	
	# Spawn damage popup
	var random_offset = Vector2(
		randf_range(-48.0, 48.0),
		randf_range(-24.0, 0.0)
	)
	DamageManager.spawnDamage(
		global_position - Vector2(45,55), 
		amount,
		Color.RED,  # Red for enemies/player damage; use Color.CYAN for healing, etc.
		random_offset
	)
	if HP <= 15000 and Dark == 0:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"modulate", Color.BLUE_VIOLET, 5)
		print("halfHP")
		Dark += 1
	if HP <= 6000 and Dark == 1:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"modulate", Color.BLUE, 3)
		print("lowHP")
		Dark += 2

func _on_area_entered(area):
	#pass # Replace with function body.
	if area.is_in_group("bullet"):
		var dmgAmount: int = randf() * 4 + area.baseDmg
		take_damage(dmgAmount)
		HP -= dmgAmount
		tookDmg = 0
		#print(HP)
		if HP <= 0:
			queue_free()
