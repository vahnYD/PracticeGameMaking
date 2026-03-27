class_name BulletResource
extends Resource

## Packed scene containing the bullet
@export var SpecificBulletScene: PackedScene

#base values of bullet:
@export var bullet_name: String = "Default bullet"
@export var damage_multiplier: float = 10.0
@export var speed: float = 400.0
@export var ability: Ability_list = Ability_list.None
@export var onDestroyScene: PackedScene = null
@export var unloadTimerValue: float = 2.0
@export var bulletPoolAmount: int = 50

enum Ability_list{
	None,
	Piercing,
	WeakPiercing,
	Exploding
}
