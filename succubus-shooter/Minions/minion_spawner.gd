class_name TheMinion_spawner
extends Node2D

var Player: PlayerCharacter

var minionRes : Array[MinionResource]
var minion_dict: Dictionary = {}

var SummonTimer: float
var spawnBox_basicspeed : float = 0.0
var spin_speed : float = 0
var use_basicmovesetting: bool

#region useCurveForSpawn
var wave_curve_data: WaveCurveData
var CurveUsed: Curve
var elapsedTime: float = 0.0
var curveProgress: float

## curveCycleDuration, default value of 2.0, lower number means faster curve movement
var curveCycleDur: float
var curCurveValue: float
var curveFlip: bool = false

#endregion
func set_curve(curve: WaveCurveData, New_cycleDur: float = 0.0):
	wave_curve_data = curve
	CurveUsed = wave_curve_data.curve
	elapsedTime = 0.0
	curveProgress = 0.0
	curveCycleDur = wave_curve_data.initial_cycleDuration
	if New_cycleDur > 0.0:
		curveCycleDur = New_cycleDur

var spawnerName: String

var spawn_queue = []
var summon_interval: float = 0.05

var waveTop : float = 256.0
var waveBot : float = -256.0

var RightLeft: bool = false
var UpDown: bool = false
var isSpinning: bool = false
var spinDir : int
# Dir = direction. 1 : spin clockwise (from right to bottom) -1 reverse that.

var spawnBox_initialmoveVector : Vector2 = Vector2(0,0)

var on_spawn = Callable()
var minion_MoveDirOverride : Callable
var distance : float = 0

var minion_Freeze: float = 0.0


@onready var spawnBox : Sprite2D = $IndicatorBox


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
	if use_basicmovesetting:
		if RightLeft:
			if spawnBox.position.x >= waveTop  : #if hitting Right, or never reached scene
				spawnBox_initialmoveVector.x = -1 # go left
			elif  spawnBox.position.x <= waveBot  or spawnBox.global_position.x < 0: #if hitting Left
				spawnBox_initialmoveVector.x = 1 # go right

		if UpDown:
			if spawnBox.position.y >= waveTop  or spawnBox.global_position.y > GlobalScripts.max_ScreenSize.y - 32 : #if hitting top, remember, y pos is flipped.
				spawnBox_initialmoveVector.y = -1 # go up
			elif  spawnBox.position.y <= waveBot or spawnBox.global_position.y < 32.0: #if hitting bottom
				spawnBox_initialmoveVector.y = 1 # go down
		spawnBox.position += spawnBox_initialmoveVector.normalized() * delta * spawnBox_basicspeed

	elif use_basicmovesetting == false and wave_curve_data != null:
		elapsedTime += delta
		if wave_curve_data.initial_readType == wave_curve_data.readtype.pingpong:
			curveProgress = pingpong(elapsedTime, curveCycleDur) / curveCycleDur
		elif wave_curve_data.initial_readType == wave_curve_data.readtype.fmod:
			curveProgress = fmod(elapsedTime, curveCycleDur) / curveCycleDur
		# sample the curve (0→1 output)
		curCurveValue = CurveUsed.sample(curveProgress)
		if curveFlip:
			curCurveValue = 1.0 - curCurveValue
		# remap 0→1 to WaveBot→WaveTop
		if UpDown:
			spawnBox.position.y = lerp(waveBot, waveTop, curCurveValue)
		if RightLeft:
			spawnBox.position.x = clamp(lerp(waveBot, waveTop, curCurveValue),32.0,GlobalScripts.max_ScreenSize.x + 200.0)
		
		
	if isSpinning:
		rotation_degrees += delta * spin_speed * spinDir
	
	if spawn_queue.size() > 0:
		show()
		SummonTimer += delta
		if SummonTimer < summon_interval: return
		SummonTimer -= summon_interval 
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
	MinionsPool.put_minion_toGame(data, spawnBox.global_position)

func spawnMinion_chasingPlayer(chaseDuration: float):
	var data = spawn_queue.pop_front() as MinionResource
	var getDir = _seekPlayer()
	minion_MoveDirOverride = func(minion_referenced : basic_minion, _delta): 
		_dirChange(minion_referenced, getDir)
	on_spawn = func(minion_ref : basic_minion) :
		changeOverrideTimer(minion_ref,chaseDuration)
	MinionsPool.put_minion_toGame(data, spawnBox.global_position, on_spawn, minion_MoveDirOverride)

func spawnMinion_spinning(movDirOverrideDuration : float):
	var data = spawn_queue.pop_front() as MinionResource
	var getDir = _getRotationAngle() 
	minion_MoveDirOverride = func(minion_referenced : basic_minion, _delta): 
		_dirChange(minion_referenced, getDir)
	on_spawn = func(minion_ref : basic_minion) :
		changeOverrideTimer(minion_ref,movDirOverrideDuration)
	MinionsPool.put_minion_toGame(data, spawnBox.global_position, on_spawn, minion_MoveDirOverride)

func _dirChange(minion: basic_minion, newDir: Vector2):
	minion.movedir = newDir

func SummonEnemy_call(minSpawnParam: SummonConfig, spawnType: global_enums.Minion_SpawnType):
	curSpawnType = spawnType
	summon_interval = minSpawnParam.summon_interval
	wave_curve_data = minSpawnParam.wave_curve_data
	use_basicmovesetting = minSpawnParam.use_basicmovesetting
	if use_basicmovesetting == true:
		spawnBox_basicspeed = minSpawnParam.spawnBox_basicspeed
	elif use_basicmovesetting == false:
		elapsedTime = curveCycleDur * minSpawnParam.Curve_startAt
		curveFlip = minSpawnParam.movCurveFlip
		set_curve(minSpawnParam.wave_curve_data, minSpawnParam.WaveCurveDuration)
		
	if minSpawnParam.spawnBox_initialmoveVector.x != 0:
		RightLeft = true
	else:
		RightLeft = false
	if  minSpawnParam.spawnBox_initialmoveVector.y != 0:
		UpDown = true
	else:
		UpDown = false
	if minSpawnParam.isSpin != 0:
		isSpinning = true
	else:
		isSpinning = false
	spin_speed = minSpawnParam.spin_speed
	spawnBox.position = minSpawnParam.spawnBox_initialPos
	spawnBox_initialmoveVector = minSpawnParam.spawnBox_initialmoveVector
	minion_MoveDirOverride = minSpawnParam.minion_MoveDirOverride
	spinDir = minSpawnParam.isSpin
	waveTop = minSpawnParam.wave_size
	waveBot = - minSpawnParam.wave_size
	minion_Freeze = minSpawnParam.freezeTime
	for i in range(minSpawnParam.enemy_count):
		spawn_queue.append(get_minion_by_name(minSpawnParam.minionName))
		

func _dpsTest(minion: basic_minion, duration: float): ## fully deprecated, just meant as a test.
	minion.specific_HealthComponent.take_damage(12.0)

func changeOverrideTimer(minion: basic_minion, duration: float):
	minion.specific_movOverrideTimer = duration

func _seekPlayer() -> Vector2:
	return spawnBox.global_position.direction_to(Player.global_position) 
	
func _getRotationAngle() -> Vector2:
	if isSpinning:
		return -spawnBox.global_position.direction_to(self.global_position)
	else:
		return Vector2.ZERO

func _freeze_minion(minion: Node, duration: float):
	minion.set_physics_process(false)
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(minion):
		minion.set_physics_process(true)
