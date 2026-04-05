# Enemy_Res.gd
class_name EnemyResources
extends Resource

@export var enemy_name: String = "unknown"
@export var HP: float = 10.0
@export var ATK: float = 5.0
@export var DEF: float = 0.0
@export var move_spd: float = 300.0
@export var move_type: GlobalTypes.enemy_move_types = GlobalTypes.enemy_move_types.straight
@export var base_difficulty: float = 1.0

@export var sprite: SpriteFrames
@export var collision_shape : Shape2D
