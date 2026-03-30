class_name TheMinion_spawner
extends Node2D

var Player: PlayerCharacter

var minionRes : Array[MinionResource]
var minion_dict: Dictionary = {}

var SummonTimer: float
var WaveSpeed : float = 0.0
var SpinSpeed : float = 0
var useBasicWave: bool

#region useCurveForSpawn
var waveCurveDataUsed: WaveCurveData
var CurveUsed: Curve
var elapsedTime: float = 0.0
var curveProgress: float

## curveCycleDuration, default value of 2.0, lower number means faster curve movement
var curveCycleDur: float
var curCurveValue: float
var curveFlip: bool = false

#endregion
func set_curve(curve: WaveCurveData, New_cycleDur: float = 0.0):
	waveCurveDataUsed = curve
	CurveUsed = waveCurveDataUsed.curve
	elapsedTime = 0.0
	curveProgress = 0.0
	curveCycleDur = waveCurveDataUsed.initial_cycleDuration
	if New_cycleDur > 0.0:
		curveCycleDur = New_cycleDur

var spawnerName: String

var spawn_queue = []
var SPAWN_INTERVAL: float = 0.05

var waveTop : float = 256.0
var waveBot : float = -256.0

var RightLeft: bool = false
var UpDown: bool = false
var isSpinning: bool = false
var spinDir : int
# Dir = direction. 1 : spin clockwise (from right to bottom) -1 reverse that.

var Spawner_MoveDir : Vector2 = Vector2(0,0)

var on_spawn = Callable()
var minion_MoveDirOverride : Callable
var distance : float = 0

var minion_Freeze: float = 0.0


@onready var iBox : Sprite2D = $IndicatorBox


var curSpawnType : global_enums.Minion_SpawnType


func prep(res: Array[MinionResource]):
	
	Player = get_tree().get_first_node_in_group("thePlayer")
	# Build the dictionary once, ideally when game starts, done by gameLevelManager.
	minionRes = res
	for minion in minionRes:
		minion_dict[minion.base_MinionName] = minion

		
func get_minion_by_name(target_name: String) -> MinionResource:
	# .get() will return the minion, or null if the name doesn't exist
	return minion_dict.get(target_name, null)


func _process(delta):
	if useBasicWave:
		if RightLeft:
			if iBox.position.x >= waveTop  : #if hitting Right, or never reached scene
				Spawner_MoveDir.x = -1 # go left
			elif  iBox.position.x <= waveBot  or iBox.global_position.x < 0: #if hitting Left
				Spawner_MoveDir.x = 1 # go right

		if UpDown:
			if iBox.position.y >= waveTop  or iBox.global_position.y > GlobalScripts.max_ScreenSize.y - 32 : #if hitting top, remember, y pos is flipped.
				Spawner_MoveDir.y = -1 # go up
			elif  iBox.position.y <= waveBot or iBox.global_position.y < 32.0: #if hitting bottom
				Spawner_MoveDir.y = 1 # go down
		iBox.position += Spawner_MoveDir.normalized() * delta * WaveSpeed

	elif useBasicWave == false and waveCurveDataUsed != null:
		elapsedTime += delta
		if waveCurveDataUsed.initial_readType == waveCurveDataUsed.readtype.pingpong:
			curveProgress = pingpong(elapsedTime, curveCycleDur) / curveCycleDur
		elif waveCurveDataUsed.initial_readType == waveCurveDataUsed.readtype.fmod:
			curveProgress = fmod(elapsedTime, curveCycleDur) / curveCycleDur
		# sample the curve (0→1 output)
		curCurveValue = CurveUsed.sample(curveProgress)
		if curveFlip:
			curCurveValue = 1.0 - curCurveValue
		# remap 0→1 to WaveBot→WaveTop
		if UpDown:
			iBox.position.y = lerp(waveBot, waveTop, curCurveValue)
		if RightLeft:
			iBox.position.x = clamp(lerp(waveBot, waveTop, curCurveValue),32.0,GlobalScripts.max_ScreenSize.x + 200.0)
		
		
	if isSpinning:
		rotation_degrees += delta * SpinSpeed * spinDir
	
	if spawn_queue.size() > 0:
		show()
		SummonTimer += delta
		if SummonTimer < SPAWN_INTERVAL: return
		SummonTimer -= SPAWN_INTERVAL 
		match curSpawnType:
			global_enums.Minion_SpawnType.basic:
				spawnMinion_normal()
			global_enums.Minion_SpawnType.chasing_player:
				spawnMinion_chasingPlayer(1.5)
			global_enums.Minion_SpawnType.spinning:
				spawnMinion_spinning(5.0)
	else:
		hide()

func spawnMinion_normal():
	var data = spawn_queue.pop_front() as MinionResource
	MinionsPool.put_minion_toGame(data, iBox.global_position)

func spawnMinion_chasingPlayer(chaseDuration: float):
	var data = spawn_queue.pop_front() as MinionResource
	var getDir = _seekPlayer()
	minion_MoveDirOverride = func(minion_referenced : basic_minion, _delta): 
		_dirChange(minion_referenced, getDir)
	on_spawn = func(minion_ref : basic_minion) :
		changeOverrideTimer(minion_ref,chaseDuration)
	MinionsPool.put_minion_toGame(data, iBox.global_position, on_spawn, minion_MoveDirOverride)

func spawnMinion_spinning(movDirOverrideDuration : float):
	var data = spawn_queue.pop_front() as MinionResource
	var getDir = _getRotationAngle() 
	minion_MoveDirOverride = func(minion_referenced : basic_minion, _delta): 
		_dirChange(minion_referenced, getDir)
	on_spawn = func(minion_ref : basic_minion) :
		changeOverrideTimer(minion_ref,movDirOverrideDuration)
	MinionsPool.put_minion_toGame(data, iBox.global_position, on_spawn, minion_MoveDirOverride)

func _dirChange(minion: basic_minion, newDir: Vector2):
	minion.movedir = newDir

func SummonEnemy_call(minSpawnParam: SummonConfig, spawnType: global_enums.Minion_SpawnType):
	curSpawnType = spawnType
	SPAWN_INTERVAL = minSpawnParam.summonInterval
	waveCurveDataUsed = minSpawnParam.movementCurve
	useBasicWave = minSpawnParam.useBasicMovSet
	if useBasicWave == true:
		WaveSpeed = minSpawnParam.spawnerMoveSpeed
	elif useBasicWave == false:
		elapsedTime = curveCycleDur * minSpawnParam.start_at
		curveFlip = minSpawnParam.movCurveFlip
		set_curve(minSpawnParam.movementCurve, minSpawnParam.WaveCurveDuration)
		
	if minSpawnParam.initialMovVector.x != 0:
		RightLeft = true
	else:
		RightLeft = false
	if  minSpawnParam.initialMovVector.y != 0:
		UpDown = true
	else:
		UpDown = false
	if minSpawnParam.isSpin != 0:
		isSpinning = true
	else:
		isSpinning = false
	SpinSpeed = minSpawnParam.spinSpeed
	iBox.position = minSpawnParam.initialPos
	Spawner_MoveDir = minSpawnParam.initialMovVector
	minion_MoveDirOverride = minSpawnParam.movDirOverride
	spinDir = minSpawnParam.isSpin
	waveTop = minSpawnParam.waveSize
	waveBot = - minSpawnParam.waveSize
	minion_Freeze = minSpawnParam.freezeTime
	for i in range(minSpawnParam.enemy_count):
		spawn_queue.append(get_minion_by_name(minSpawnParam.minionName))
		

func _dpsTest(minion: basic_minion, duration: float): ## fully deprecated, just meant as a test.
	minion.specific_HealthComponent.take_damage(12.0)

func changeOverrideTimer(minion: basic_minion, duration: float):
	minion.specific_movOverrideTimer = duration

func _seekPlayer() -> Vector2:
	return iBox.global_position.direction_to(Player.global_position) 
	
func _getRotationAngle() -> Vector2:
	if isSpinning:
		return -iBox.global_position.direction_to(self.global_position)
	else:
		return Vector2.ZERO

func _freeze_minion(minion: Node, duration: float):
	minion.set_physics_process(false)
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(minion):
		minion.set_physics_process(true)
