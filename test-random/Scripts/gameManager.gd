extends Node2D

signal DifficultyIncreased(DifLevel: int)
@onready var timer: SceneTreeTimer
var Player: PackedScene

#@onready var SpawnPoints: Array[Marker2D] = [$SpawnPoint2, $SpawnPoint3, $SpawnPoint4, $SpawnPoint5, $SpawnPoint6]
var DifLevel: int = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	timeLoop()
	
	pass # Replace with function body.

func timeLoop():
	timer = get_tree().create_timer(20)
	timer.timeout.connect(DifIncrease)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func DifIncrease():
	DifLevel += 1
	emit_signal("DifficultyIncreased",DifLevel)
	timeLoop()
	
