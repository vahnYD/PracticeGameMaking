extends Sprite2D
var HealthMaxLength: float = 100
var CurrentHealth: float = 100
var InitialScale: float

func _ready():
	InitialScale = transform.get_scale().x
	updateBar(HealthMaxLength, HealthMaxLength)

func updateBar(newHealth: float, newMaxHealth: float):
	CurrentHealth = newHealth
	HealthMaxLength = newMaxHealth
	scale.x = (CurrentHealth / HealthMaxLength) * InitialScale
