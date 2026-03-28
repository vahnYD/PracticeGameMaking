class_name BasicBulletHit
extends Area2D

signal bulletHit(hit: Area2D)

func _ready():
	await get_tree().process_frame
	add_to_group("Bullet")

func _on_area_entered(area):
	if  area.is_in_group("Enemy"):
		bulletHit.emit(area)
	if area.is_in_group("KillZone"):
		bulletHit.emit(area)
