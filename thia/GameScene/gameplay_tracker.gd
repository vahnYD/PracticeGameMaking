extends Node2D

## how much the BG slides to the left, per second.
@export var slide_speed: float  = 24.0
@onready var BGPic : Sprite2D = $BGPic
@onready var enemyContainer : EnemyContainer = $enemyContainer

func _ready():
	BGPic.slide_speed = slide_speed
	enemyContainer.spawner_slide_speed = slide_speed
