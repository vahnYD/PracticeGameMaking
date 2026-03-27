extends Area2D

signal bulletHit(enemy: Area2D)
func _on_area_entered(area):
	
	if area.is_in_group("Enemy"):
		bulletHit.emit(area)
		pass
	pass # Replace with function body.
