class_name enemy_resources
extends Resource

@export var HP : float = 10.0
@export var mov_speed: float = 10.0
@export var ATK: float = 3.0
@export var atk_speed: float = 1.0
@export var DEF: float = 0.0
@export var enemy_name: String = "unknown"

## higher spawn weight means more likely to be summoned
@export var spawn_weight: float = 10.0

## calculated based from spawn_weight and total weight of all affordable enemies.
var rarity: float = 0.0

@export var collisionRadius :float = 100.0
@export var sprite_frames : SpriteFrames
