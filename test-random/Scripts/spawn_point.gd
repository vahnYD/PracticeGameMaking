extends Marker2D

@export var Minion_scene: PackedScene  # Drag Minion.tscn here in main scene
@export var timing: float

@onready var SpawnCheck: Area2D = $Area2D

#@onready var timer: Timer = $Timer
var curLevel: int = 1
var MinionBonusHP: float = 0
var MinionBonusSpeed: float = 0


func _ready():
	#timer.wait_time += timing
	#timer.timeout.connect(_shoot)
	pass

func Spawn():
	
	checkCurLevel()
	var Minion = Minion_scene.instantiate()

	Minion.transform = transform  # Copies position + rotation
	#get_tree().current_scene.add_child(Minion)
	get_tree().current_scene.call_deferred("add_child", Minion)
	
	Minion.HP += MinionBonusHP
	Minion.Speed += MinionBonusSpeed
	Minion.level += curLevel

func checkCurLevel():
	if GameManager.DifLevel == 2:
		if curLevel == 1:
			#timer.wait_time -= 0.25
			MinionBonusHP += 15
			MinionBonusSpeed += 25
			curLevel+= 1
	
	if GameManager.DifLevel == 3:
		if curLevel == 2:
			#timer.wait_time -= 0.1
			MinionBonusHP += 60
			MinionBonusSpeed += 25
			curLevel+= 1
	
	if GameManager.DifLevel == 4:
		if curLevel == 3:
			#timer.wait_time -= 0.5
			MinionBonusHP += 120
			MinionBonusSpeed += 25
			curLevel+= 1
	if GameManager.DifLevel == 5:
		if curLevel == 4:
			#timer.wait_time -= 0.65
			MinionBonusHP += 150
			MinionBonusSpeed += 15
			curLevel+= 1
			
	  # Adds to root scene


func _on_area_2d_area_entered(area):
	if area.is_in_group("SpawnCheckbox"):
		Spawn()
