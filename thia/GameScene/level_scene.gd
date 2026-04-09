# level_scene.gd
extends Node2D

@export var curlevel_Enemies : Array[EnemyResources]
@export var cur_level_dif: float = 0.0

@onready var enemy_container : EnemyContainer = $gameplayTracker/enemyContainer
@onready var Camera: Cam = $Camera2D

var Player: PlayerCharacter
var elapsedTime: float = 0.0

func _ready():
	Player = get_tree().get_first_node_in_group("thePlayer")
	Camera.load_player(Player)
	enemy_container.build_curLevel_dict(curlevel_Enemies,cur_level_dif)
	enemy_container.Player = Player

func _process(delta):
	elapsedTime += delta
