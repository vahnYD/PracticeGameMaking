class_name TheMinion_spawner
extends Node2D

@export var minionRes : Array[MinionResource]
var minion_dict: Dictionary = {}
@export var SummonTimer: float

@export var WaveSpeed : float = 0.0
@export var SpinSpeed : float = 0

var spawnerName: String

var spawn_queue = []
var SPAWN_INTERVAL: float = 0.05

const waveTop : float = 256.0
const waveBot : float = -256.0
var CurWaveScale: float

var RightLeft: bool = false
var UpDown: bool = false
var isSpinning: bool = false
var spinDir : int

var moveDir : Vector2 = Vector2(0,0)

var distance : float = 0

@onready var iBox : Sprite2D = $IndicatorBox

func prep(res: Array[MinionResource]):
	# Build the dictionary once, ideally when game starts, done by gameLevelManager.
	minionRes = res
	for minion in minionRes:
		minion_dict[minion.base_MinionName] = minion
		
func get_minion_by_name(target_name: String) -> MinionResource:
	# .get() will return the minion, or null if the name doesn't exist
	return minion_dict.get(target_name, null)

func _process(delta):
	
	if RightLeft:
		if iBox.position.x >= waveTop * CurWaveScale: #if hitting Right
			moveDir.x = -1 # go left
		elif  iBox.position.x <= waveBot * CurWaveScale: #if hitting Left
			moveDir.x = 1 # go right
	
	if UpDown:
		if iBox.position.y >= waveTop * CurWaveScale : #if hitting top, remember, y pos is flipped.
			moveDir.y = -1 # go down
		elif  iBox.position.y <= waveBot * CurWaveScale: #if hitting bottom
			moveDir.y = 1 # go up
	iBox.position += moveDir.normalized() * delta * WaveSpeed
	
	if isSpinning:
		rotation_degrees += delta * SpinSpeed * spinDir
	
	if spawn_queue.size() > 0:
		show()
		SummonTimer += delta
		if SummonTimer < SPAWN_INTERVAL: return
		SummonTimer -= SPAWN_INTERVAL 
		var data = spawn_queue.pop_front() as MinionResource
		MinionsPool.put_minion_toGame(data, iBox.global_position, 0)
	else:
		hide()

func SummonEnemy(minionName: String, enemy_count: int, summonInterval: float, spawnerMovSpeed: float,
isRightleft: int, isUpDown: int, isSpin: int, spinSpd: float, waveScale: float, spinStaticDistance: Vector2 = Vector2.ZERO):
	# to explain: isRightleft -1 means starts the movement from left to right, 1 = right > left
	# to explain: isUpDown -1 means starts the movement from Down to Up, 1 = Up > Down.
	# isSpin 1 = go clockwise (from right to down), -1 reverse that.
	SPAWN_INTERVAL = summonInterval
	WaveSpeed = spawnerMovSpeed
	if isRightleft != 0:
		RightLeft = true
	if isUpDown != 0:
		UpDown = true
	if isSpin != 0:
		isSpinning = true
	SpinSpeed = spinSpd
	iBox.position = spinStaticDistance
	moveDir = Vector2(isRightleft,isUpDown)
	spinDir = isSpin
	CurWaveScale = waveScale
	
	for i in range(enemy_count):
		spawn_queue.append(get_minion_by_name(minionName))
