class_name Spawner_Group
extends Node

## the order where this spawner group is activated. starting from 0
@export_range(0,7,1)             var queue_no: int       = 0

## difficulty of the spawner group aka Storm
@export_range(0.1,9,0.1)             var dif_level: float      = 1

## 1: very low, like 20 enemies total ; 5: medium, around 200 enemies total ; 9: very high, 600+
@export_range(1,9,1)             var density_level : int = 1

## in seconds, how long does the wave setup lasts.
@export_range(12.0 , 245.0, 0.1)   var duration : float   = 12.0

## is this spawner group a main one (small amount of huge continuous wave) or popcorn (small amount 
##  of enemies spawns in a lot of waves). typically main one has under 12 EnemySpawner, while
## popcorn has 9 up to 24
## PowerUp waves has a lot of enemies, but they are weak.
@export_enum("main", "popcorn", "Power Up")  var group_flag: String      = "main" 

var isActive: bool = false
var ongoingDiff: float = 0.0


signal UpgradeOnGoingDif(value)

var activate_time : float
var UpgradeTimer: float = 9999.0
func update_spawners(_slide_speed: float):
	UpgradeTimer = activate_time
	for child in get_children():
		if child is EnemySpawnerBox:
			if child.spawner_type == "followBG":
				child.global_position.x += activate_time * _slide_speed 

			elif child.spawner_type == "static":
				child.staticTime += activate_time 
			child.start_game()

var UpgradeNow: bool = false
func _process(delta):
	UpgradeTimer -= delta
	if UpgradeTimer <= 0 and UpgradeNow == false:
		UpgradeNow = true
		UpgradeOnGoingDif.emit(dif_level)
		
		
	
