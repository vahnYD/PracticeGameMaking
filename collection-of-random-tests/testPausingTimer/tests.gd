extends Node2D
@onready var attack_timer: Timer = $Timer
@export var explanationTxt: Label

var mouse_held : bool = false
var can_attack : bool = true

func _ready():
	
	attack_timer.wait_time = 0.5
	attack_timer.timeout.connect(_on_attack_tick)
		
func _process(delta):
	if not explanationTxt == null:
		explanationTxt.text = str(snapped(attack_timer.time_left, 0.001))

func _input(event):
	if event.is_action_pressed("attack"):
		mouse_held = true
		attack_timer.paused = false
		try_start_attacking()     

	elif event.is_action_released("attack"):
		mouse_held = false
		attack_timer.paused = true
		#attack_timer.stop()
		
			#if attack_timer.paused = true is not used and I'm using .stop() instead, the timer needs to run fully before 
			#the code works

func try_start_attacking():
	if mouse_held and can_attack and attack_timer.is_stopped():
		attack_timer.start()

func _on_attack_tick():
	if not mouse_held or not can_attack:
		#attack_timer.stop()
		attack_timer.paused = true
		return

	perform_attack()

func perform_attack():
	print("Attack executed")

func on_player_hit():
	can_attack = false
	attack_timer.paused = true
	#attack_timer.stop()

	await get_tree().create_timer(0.4).timeout
	can_attack = true
	try_start_attacking()
