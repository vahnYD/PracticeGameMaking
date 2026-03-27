# enemy_data.gd
class_name EnemyData
extends Resource

@export var enemy_name: String = "Unknown"
@export var max_health: float = 100
@export var attack_damage: float = 10
@export var speed: float = 50.0
@export var sprite_frames: SpriteFrames  # drag your sprite frames here in the Inspector
@export var Armor: float = 5
@export var SummonWeight: int = 1

@export var idle_anim: String = "idle"
@export var attack_anim: String = "attack"
@export var death_anim: String = "death"

#@export var scene: PackedScene
