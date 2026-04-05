class_name MinionResource
extends Resource


@export var collision_shape: Shape2D = null
#base values of bullet:
@export var base_MinionName: String = "Unknown"
@export var base_max_health: int = 1
@export var base_speed: float = 10
@export var base_touchDamage: int = 1
@export var animations: SpriteFrames = null
@export var powers: Array[basic_power] = [basic_power.none]
@export var lifeTime: float = 10.0
@export var type: basic_types
@export var move_type: GlobalEnums.Minion_moveType = GlobalEnums.Minion_moveType.basic
@export var freeze_time: float = 0.0
@export var moveDirOverride: Vector2 = Vector2.ZERO

enum basic_power{
	none,
	shield,
	haste,
	stun,
	slow
}

enum basic_types{
	weak,
	normal,
	Elite,
	Special
}
