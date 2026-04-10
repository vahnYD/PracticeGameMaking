extends Area2D

func _physics_process(delta):
	for items in get_overlapping_areas():
		var direction = (global_position - items.global_position).normalized()
		items.global_position += direction * 888.0 * delta
