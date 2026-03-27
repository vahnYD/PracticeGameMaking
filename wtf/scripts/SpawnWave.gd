# SpawnWave.gd
# Defines one spawn event in a level's wave sequence.
class_name SpawnWave
extends Resource

@export var enemy_ids: Array[String] = []  # List of enemy types in this wave
@export var count: int = 10               # Total enemies to spawn
@export var interval_sec: float = 3.0     # Seconds between each wave of this type
@export var start_at_sec: float = 0.0     # Level time when this wave pattern activates
@export var end_at_sec: float = -1.0      # -1 = never ends

# Weighted random pick from enemy_ids
func pick_enemy() -> String:
	if enemy_ids.is_empty():
		return ""
	return enemy_ids[randi() % enemy_ids.size()]
