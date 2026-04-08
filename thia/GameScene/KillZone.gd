class_name Kill_Zone
extends Area2D


func _on_area_entered(area):
	if area is Enemy:
		area.deactivate()
		
