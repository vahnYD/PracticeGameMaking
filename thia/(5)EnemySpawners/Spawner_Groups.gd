class_name spawner_group
extends Node

## 1: very low, like 20 enemies total ; 5: medium, around 200 enemies total ; 9: very high, 600+
@export_range(1,9,1)             var density_level : int     = 1

## in seconds, how long does the wave setup lasts.
@export_range(3.0 , 90.0, 0.1)   var duration : float        = 5.0

## is this spawner group a main one (small amount of huge continuous wave) or popcorn (small amount 
##  of enemies spawns in a lot of waves). typically main one has under 12 EnemySpawner, while
## popcorn has 9 up to 24
@export_enum("main", "popcorn")  var group_type: String      = "main" 

var isActive: bool = false
