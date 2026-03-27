class_name TheMinion_spawner
extends Node2D

@onready var tempSpawnTimer: Timer = $temporaryTimer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var SpawnTiming: Timer = $SpawnTiming

@export var minionRes : MinionResource
@export var spawnAngle: float

func spawn_minion():
	show()
	animation.play("SpawnAnimation")
	await SpawnTiming.timeout
	MinionsPool.put_minion_toGame(minionRes,global_position,rotation)
	

func _on_temporary_timer_timeout():
	spawn_minion()
	SpawnTiming.start(0.2)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SpawnAnimation":
		hide()
		
		
func get_SpawnAngle(angle:float):
	spawnAngle = angle
