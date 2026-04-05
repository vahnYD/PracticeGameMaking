extends Node2D

var StoredSpawners : Array[TheMinion_spawner]
@export var ThisLevel_Minions : Array[MinionResource]
@export var spawnerSceneRef : PackedScene
@export var spawnerCount : int
@export var CommonSpawnPos: Array[Marker2D]
@export var Curvelist: Array[WaveCurveData]
#region useCurveForSpawn
var spdCurve: WaveCurveData
var CurveUsed: Curve
var curveCycleDur: float
var initial_CurveValue : float 
var wave_dict: Dictionary ={}
#endregion
func get_curve_byname(curve_name: String) -> WaveCurveData:
	spdCurve = wave_dict.get(curve_name)
	CurveUsed = spdCurve.curve
	curveCycleDur = spdCurve.initial_cycleDuration
	return spdCurve

var SpawnEventCount : int
var gameTime: float

func createSpawnerInstance():
	for count in range(spawnerCount):
		var spawner = spawnerSceneRef.instantiate() as TheMinion_spawner
		add_child(spawner)
		spawner.spawnerName = "SpawnerNo" + str(count)
		spawner.prep(ThisLevel_Minions)
		StoredSpawners.append(spawner)

func grabSpawner() -> TheMinion_spawner:
	return StoredSpawners.pop_front()
	
func _ready():
	
	createSpawnerInstance()
	for curves in Curvelist:
		wave_dict[curves.curve_name] = curves

func _process(delta):
	gameTime += delta
	
	if gameTime >= 3 and SpawnEventCount <= 0:
		SpawnEventCount += 1

		BasicSpawning(CommonSpawnPos[0].global_position, SpawningPattern_basic("Igeon", 55, Vector2(0,1), Vector2(0,256)))
		
		#var curveData = get_curve_byname("ease")
		#BasicSpawning(CommonSpawnPos[1].global_position,SpawningPattern_useCurve("Igeon", 55,curveData,Vector2(0,1), true,1.2))
		SpinningSpawning(CommonSpawnPos[1].global_position,
		SpawningPattern_spin("Igeon", 55, Vector2(0,-256), -1))


func SpawningPattern_basic(minion_name: String, spawnCount: int, moveVector: Vector2, 
spawnBox_initialPos : Vector2 = Vector2.ZERO) -> SummonConfig:
	var curParamSetup = SummonConfig.new()
	curParamSetup.minionName = minion_name
	curParamSetup.enemy_count = spawnCount
	curParamSetup.spawnBox_initialmoveVector = moveVector
	curParamSetup.spawnBox_initialPos = spawnBox_initialPos
	curParamSetup.summon_interval = 0.1333
	curParamSetup.spawnBox_basicspeed = 450.0
	
	return curParamSetup
	
func SpawningPattern_useCurve(minion_name: String, spawnCount: int, curvePattern: WaveCurveData, moveXorY: Vector2, 
curveFlip : bool = false, curveDur: float = 2.0) -> SummonConfig:
	var curParamSetup = SummonConfig.new()
	curParamSetup.minionName = minion_name
	curParamSetup.enemy_count = spawnCount
	curParamSetup.use_basicmovesetting = false
	curParamSetup.spawnBox_initialmoveVector = moveXorY
	curParamSetup.wave_curve_data = curvePattern
	curParamSetup.movCurveFlip = curveFlip
	curParamSetup.WaveCurveDuration = curveDur
	curParamSetup.summon_interval = 0.1333

	return curParamSetup
	
func SpawningPattern_spin(minion_name: String, spawnCount: int, radius: Vector2, 
spinDir : int)-> SummonConfig:
	var curParamSetup = SummonConfig.new()
	curParamSetup.minionName = minion_name
	curParamSetup.enemy_count = spawnCount
	curParamSetup.isSpin = spinDir
	curParamSetup.spawnBox_initialPos = radius
	curParamSetup.summon_interval = 0.1
	curParamSetup.spin_speed = 250.0
	return curParamSetup

func BasicSpawning(startPos: Vector2, config : SummonConfig):
	var activeSpawnerInstance = grabSpawner()
	activeSpawnerInstance.global_position = startPos
	activeSpawnerInstance.SummonEnemy_call(config, GlobalEnums.Minion_SpawnType.basic)

func SpinningSpawning(startPos: Vector2 , config : SummonConfig):
	var activeSpawnerInstance = grabSpawner()
	activeSpawnerInstance.global_position = startPos
	activeSpawnerInstance.SummonEnemy_call(config, GlobalEnums.Minion_SpawnType.spinning)
	
