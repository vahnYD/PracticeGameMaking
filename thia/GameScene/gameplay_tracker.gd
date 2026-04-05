extends Node2D

@export var slide_speed: float  = 24.0
@onready var BGPic : Sprite2D = $BGPic
@onready var enemyContainer : EnemyContainer = $enemyContainer

func _ready():
	BGPic.slide_speed = slide_speed
	enemyContainer.spawner_slide_speed = slide_speed
