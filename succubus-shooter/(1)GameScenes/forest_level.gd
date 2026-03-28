extends Node2D

var StoredSpawners : Array[TheMinion_spawner]
@export var ThisLevel_Minions : Array[MinionResource]
@export var spawnerSceneRef : PackedScene
var spawnerCount : int
var SpawnEventCount : int
var gameTime: float

func createSpawnerInstance():
	var spawner = spawnerSceneRef.instantiate() as TheMinion_spawner
	add_child(spawner)
	spawner.spawnerName = "SpawnerNo" + str(spawnerCount)
	spawner.prep(ThisLevel_Minions)
	StoredSpawners.append(spawner)

func grabSpawner() -> TheMinion_spawner:
	return StoredSpawners.pop_front()
	
func _ready():
	createSpawnerInstance()

func _process(delta):
	gameTime += delta
	
	if gameTime >= 3 and SpawnEventCount <= 0:
		SpawnEventCount += 1
		BasicUpDownWaveSpawn(Vector2(2800, 800), "Igeon", 40,0.5)

func BasicUpDownWaveSpawn(startPos: Vector2, minion_name: String, summon_amount: int, waveWideness: float):
	var activeSpawnerInstance = grabSpawner()
	activeSpawnerInstance.global_position = startPos
	activeSpawnerInstance.SummonEnemy(minion_name,summon_amount,0.1,600.0,0,1,0,0.0,waveWideness)

	
