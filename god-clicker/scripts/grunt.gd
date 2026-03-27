extends Base_Enemy

func _init():
	super("Grunt", 15.0, 0.8, 4)
	
func _ready():
	#speed = 15.0 
	#aggroFloat = 0.8
	#difficulty = 3
	super._ready()
	health.max_health = 310.0 # Tankier
	health.current_health = 310.0
