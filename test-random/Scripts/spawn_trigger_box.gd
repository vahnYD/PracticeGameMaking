extends Area2D

@onready var SpawnSetting: AnimationPlayer = $AnimationPlayer
@export var MinionType: int

func _ready():
	GameManager.DifficultyIncreased.connect(_onDifficultyIncreased)

func _onDifficultyIncreased(DifLevel: int):
	if DifLevel == 2:
		SpawnSetting.play("UpDownFast")

	
	if DifLevel == 3:
		SpawnSetting.play("UpUpFast")

		
	if DifLevel == 4:
		SpawnSetting.play("SuperFastUpDown")

	if DifLevel == 5:
		SpawnSetting.play("DownDownFast")
		var clone = duplicate()
		get_tree().current_scene.add_child(clone)
		clone.get_node("AnimationPlayer").play("UpUpFast")

	if DifLevel == 6:
		var clone2 = duplicate()
		get_tree().current_scene.add_child(clone2)
		clone2.get_node("AnimationPlayer").play("UpDownSlow")
		clone2.MinionType = 2

	
		
	
