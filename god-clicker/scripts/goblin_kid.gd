extends Base_Enemy

func _init():
	super("Goblin_Kid", 30.0, 2, 2)
	
func _ready():
	#speed = 30.0
	#aggroFloat = 1.4
	#difficulty = 2
	super._ready()
	health.max_health = 120.0 # Tankier
	health.current_health = 120.0
	
