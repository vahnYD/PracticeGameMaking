# Enemy_Scaled_Data.gd
class_name EnemyScaledData
extends RefCounted

var enemy_name: String = "unknown"
var HP: float = 10.0
var ATK: float = 5.0
var DEF: float = 0.0
var move_spd: float = 300.0
var move_type: GlobalTypes.enemy_move_types = GlobalTypes.enemy_move_types.straight

## is_special is a float which decides the Enemy's scale, and stat boost, defeating special enemies always
## drop some powers
var is_special : float = 0.0

var sprite: SpriteFrames
var collision_shape : Shape2D

var player_target: PlayerCharacter

var move_Override : Callable = Callable()
var move_overrideDur: float = 0.0
