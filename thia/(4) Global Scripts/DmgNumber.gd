class_name DamageNumberText
extends Node2D

@onready var dmglabel: Label = $txtPos/Label
@onready var txtPos: Node2D = $txtPos

var target: Node2D
var StoredDmg: int = 0
var base_position: Vector2

const DMGACCUMULATIONTIMER   : float = 0.05
const SHAKE_DURATION         : float = 0.05
const FADE_DURATION          : float = 0.13 
const LINGER_DURATION        : float = 0.12
const FADE_SPEED             : float = 3.0

var phase: int = 0  # 0=idle, 1=shake, 2=fade, 3=linger
var phase_timer: float = 0.0
var t: float = 0.0

func _ready():
	visible = false

func latch(_target: Node2D):
	StoredDmg = 0
	target = _target
	set_initialPos(target.dmgPosVec)

func freeSpawn(_spawnPos: Vector2):
	set_initialPos(_spawnPos)

func set_initialPos(_pos: Vector2):
	var randomOffset :Vector2 = Vector2(randf(), randf()) * 80 * [-1, 1].pick_random()
	base_position = _pos + randomOffset
	txtPos.position = base_position

func activate(_dmgAmount: int):
	StoredDmg += _dmgAmount
	dmglabel.text = str(StoredDmg)
	dmglabel.modulate.a = 1.0
	txtPos.scale = Vector2.ONE
	t = 0.0
	visible = true
	_set_phase(1)

func _set_phase(_phase: int):
	phase = _phase
	phase_timer = 0.0

func _process(delta):
	if phase == 0:
		return

	if target:
		global_position = target.global_position

	phase_timer += delta
	t += delta

	match phase:
		1: # shake
			_do_shake()
			if phase_timer >= SHAKE_DURATION:
				_set_phase(2)
		2: # fade
			txtPos.position = base_position + Vector2(8, -16) * t
			txtPos.scale = Vector2.ONE.lerp(Vector2(0.6, 0.6), t)
			dmglabel.modulate.a = clamp(1.0 - t * FADE_SPEED, 0.1, 1.0)
			if phase_timer >= FADE_DURATION:
				_set_phase(3)
		3: # linger
			if phase_timer >= LINGER_DURATION:
				_set_phase(0)
				return_to_pool()

func _do_shake():
	var intensity : int = [-8, 8].pick_random() * (1.0 - t)
	txtPos.position += Vector2(intensity, intensity)

signal DmgNumber_returned_toPool(DamageNumberText)
func return_to_pool():
	DmgNumber_returned_toPool.emit(self)
