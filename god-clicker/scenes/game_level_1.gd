extends Node2D


@onready var DifficultyIncreaseTimer: Timer = $DifficultyIncreaseTimer


@export var _LevelDifficulty: int
@export var currentDifficulty: float

var Spawners = []

func _on_ready():
	$Gameplay.LevelDifficulty = _LevelDifficulty
	currentDifficulty = _LevelDifficulty
	

func _on_difficulty_increase_timer_timeout():
	currentDifficulty += 1
	
	Spawners =  get_tree().get_nodes_in_group("Spawner")
	for Spawner in Spawners:
		Spawner.currentTimeSpawnMultiplier += 1
		Spawner.global_difficulty = currentDifficulty
		Spawner.difficulty_change()
		#print("difficulty changed!")
	pass # Replace with function body.
