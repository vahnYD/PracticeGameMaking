class_name HitboxComponent
extends Area2D

@export var health_component: HealthComponent
@onready var hurtbox: CollisionShape2D = $Hitbox

func take_damage(amount: float):
	if health_component:
		health_component.take_damage(amount)

func updateRadius(radius: float):
	hurtbox.shape.radius = radius
