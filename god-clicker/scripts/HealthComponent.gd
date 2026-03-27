extends Node

class_name HealthComponent

signal died
signal took_damage

@export var max_health: float = 100.0
var current_health: float

func _ready():
	current_health = max_health
	pass


func take_damage(amount: float):
	current_health -= amount
	took_damage.emit()
	if current_health <= 0:
		died.emit()
