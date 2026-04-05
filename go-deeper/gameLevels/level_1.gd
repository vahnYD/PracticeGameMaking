extends Node2D

@export var curLevel_enemy_resources : Array[enemy_resources] = []
@onready var gameManager: gameplay_manager = $GameplayComponent

func _ready():
	gameManager.spawn_enemyRandom(11,1)
