extends Base_Enemy

func _init():
	super("Slime", 13.0, 1.2, 1)
	
func _ready():
	super._ready()
	health.max_health = 65.0 # Tankier
	health.current_health = 65.0
