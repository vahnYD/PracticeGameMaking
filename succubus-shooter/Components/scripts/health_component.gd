class_name HealthComponent
extends Node2D


signal died
signal took_damage

@export var max_health: float = 20.0

@onready var damageAccumulationTimer: Timer = $DmgAccumulationTimer
@onready var DamageNumberLabel: Label = $DamageNumberPosition/DamageNumberLabel
@onready var DmgNumberPos: Node2D = $DamageNumberPosition


var tween: Tween = null
var _current_shake_intensity: float


var DmgNumberStaticPos: Vector2
var accumulatingDamage: bool = false
var accumulatedDamage: float = 0
var current_health: float
var dmgIntense: int

func _ready():
	await get_tree().process_frame
	DamageNumberLabel.text = ""
	current_health = max_health
	DmgNumberStaticPos = DmgNumberPos.position


func take_damage(amount: float):
	if current_health > 0:
		current_health -= amount
		accumulatedDamage += amount # pools dmg into accumulated Damage
		damageAccumulationTimer.start(1)
		if amount < 100:
			dmgIntense = 0
		elif amount < 1000:
			dmgIntense = 1
		else:
			dmgIntense = 2
		
		_damage_display_handle()
		took_damage.emit()
		if current_health <= 0:
			died.emit()
		

#func _input(event):
	#if event is InputEventMouseButton:
		#if Input.is_action_just_pressed("attack"):
			#take_damage(40)


func _on_dmg_accumulation_timer_timeout():
	accumulatingDamage = false
	accumulatedDamage = 0
	DamageNumberLabel.text = ""


func _damage_display_handle():
	var _this_tween: Tween = get_tree().create_tween()
	accumulatingDamage = true
	_this_tween.tween_property(DamageNumberLabel,"modulate", Color.WHITE, 0.01)
	DamageNumberLabel.text = str(snapped(accumulatedDamage, 1))
	shake_object(DmgNumberPos, DmgNumberStaticPos, float(dmgIntense) / 2 + 0.5, dmgIntense)
	_this_tween.tween_property(DamageNumberLabel,"modulate", Color.TRANSPARENT, dmgIntense + 0.8)

	# the code above makes damagenumberlabel visible again, display the accumulated damage in integer,
	# then shakes the damage number. float(dmgIntense) / 2 + 0.5 gives just about correct feel of 
	# shake intensity based on testings, after shaking, the number will become transparent
	


func shake_object(target_node: Node2D, Original_Position: Vector2, shake_intensity: float = 0.5, bonus_intensity: int = 0):
	if _current_shake_intensity > shake_intensity:
		return 													# stronger shake will not be overriden
	if tween != null and tween.is_running():
		tween.kill()
		target_node.position = Original_Position
	# kills a tween if there's already one, so it doesn't overlap 
	tween = create_tween()
	_current_shake_intensity = shake_intensity
	var original_pos = Original_Position
	var ShakeAmount = ceili(shake_intensity * 25) 
	var bonusShake = randi_range((bonus_intensity * -12),(bonus_intensity * 12))
	for i in range(ShakeAmount):
		var offset = Vector2([-1,1].pick_random() * randi_range(7,10) * shake_intensity + bonusShake, 
							[-1,1].pick_random() * randi_range(7,10) * shake_intensity + bonusShake)
		tween.tween_property(target_node, "position", original_pos + offset, 0.02)
		
	tween.chain().tween_property(target_node, "position", original_pos, 0.01) 	# Return to original position
	tween.tween_callback(func(): _current_shake_intensity = 0)
