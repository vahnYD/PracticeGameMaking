extends Node2D

@export var minionRes : MinionResource
@export var timerDelay:float = 0.05
@onready var spawnInterval : Timer = $Timer

func get_random_screen_point() -> Vector2:
	var screen_size: Vector2 = get_viewport_rect().size
	
	var rng := RandomNumberGenerator.new()

	var rnd_x: float = rng.randf_range(0, screen_size.x)
	var rnd_y: float = rng.randf_range(0, screen_size.y)
	
	return Vector2(rnd_x, rnd_y)

func _ready():
	spawnInterval.start(timerDelay)

func _on_timer_timeout():
	spawn_minion()


func spawn_minion():
	var pos = get_random_screen_point()
	MinionsPool.put_minion_toGame(minionRes,pos)
	
