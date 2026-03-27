extends CharacterBody2D
@export var speed : float = 120.0

@onready var bodySprite : AnimatedSprite2D = $bodyPic
@onready var right_shoulder: Node2D = $ArmR
@onready var rightArmPos : float = right_shoulder.position.x
@onready var left_shoulder: Node2D = $ArmL
@onready var leftArmPos : float = left_shoulder.position.x
@onready var right_hand: Node2D = $ArmR/handR
@onready var left_hand: Node2D = $ArmL/handL

var LArmEqWt: weaponTypes = weaponTypes.light_sword
var RArmEqWt: weaponTypes = weaponTypes.light_sword

enum weaponTypes{
	light_sword,
	medium_sword,
	heavy_sword
}

var dashCooldown : float = 0.5

var curState : State
var mouse_pos : Vector2
var direction : Vector2

var flippedSprite : int # must be either 1 (NOT flipped) or -1 (flipped)
var wieldWeapon : bool = false


const VerticalDampen : float = 0.5
enum State {
	none,
	dash,
	atk,
	def,
	hurt
}

func _ready():
	pass


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	input_direction.y *= VerticalDampen
	velocity = input_direction * speed
	
	if Input.is_action_just_pressed("dash") and curState != State.hurt and dashCooldown <= 0 and input_direction != Vector2.ZERO:
		dash()
	if dashCooldown > 0:
		dashCooldown -= delta

	move_and_slide()


func _process(delta):
	mouse_pos = get_global_mouse_position()
	direction = (mouse_pos - global_position)
	if curState == State.dash:
		if velocity.x * flippedSprite >= 0:
			bodySprite.play("Dash")
			
		elif velocity.x * flippedSprite < 0:
			bodySprite.play("dashBack")
	
	if curState != State.dash:
		if velocity.x * flippedSprite > 16:
			bodySprite.play("Walk")
		elif velocity.x * flippedSprite < -16:
			bodySprite.play("walkBack")
		else:
			bodySprite.play("Idle")
			
	if direction.x < 0 :
		bodySprite.flip_h = true
		flippedSprite = -1 # flipped
	else:
		bodySprite.flip_h = false
		flippedSprite = 1 # not flipped
	right_shoulder.position.x = rightArmPos * flippedSprite
	left_shoulder.position.x = leftArmPos * flippedSprite
	right_hand.scale.x = flippedSprite
	left_hand.scale.x = flippedSprite


func dash():
	curState = State.dash
	dashCooldown = 0.5
	speed += 200
	await get_tree().create_timer(0.2).timeout
	curState = State.none
	speed -= 200


func changeEq(weapon: PackedScene):
	var weapInstance = weapon.instantiate()
	if not wieldWeapon == true:
		wieldWeapon = true
		$ArmR/handR/handPic.visible = false
		right_hand.add_child(weapInstance )
		
	else:
		for child in right_hand.get_children():
			if child.is_in_group("Weapon"):
				child.queue_free()
				right_hand.add_child(weapInstance)
	pass

func _on_hurt_box_area_entered(area):
	if area.has_signal("UpgradeReceived"):
		changeEq(area.Upgrade())
		area.queue_free()
