class_name EnemyPool

var _pools: Dictionary = {}  # { PackedScene: Array[Node] }

func _ready():
	pass

## Pre-warm the pool with a given count per scene
func prewarm(scene: PackedScene, count: int, parent: Node):
	if not _pools.has(scene):
		_pools[scene] = []
	for i in count:
		var instance = scene.instantiate()
		instance.set_meta("pool_scene", scene)  # remember which pool it belongs to
		instance.visible = false
		instance.set_process(false)
		instance.set_physics_process(false)
		parent.add_child(instance)
		_pools[scene].append(instance)

## Get a ready instance from the pool, expanding if needed
func acquire(scene: PackedScene, parent: Node) -> Node:
	if not _pools.has(scene):
		_pools[scene] = []

	# Find a free (invisible/inactive) instance
	for instance in _pools[scene]:
		if not instance.visible:
			return instance

	# Pool exhausted — create a new one and add it to the pool
	var instance = scene.instantiate()
	instance.set_meta("pool_scene", scene)
	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
	parent.add_child(instance)
	_pools[scene].append(instance)
	return instance

## Call this on the enemy instead of queue_free()
func release(instance: Node):
	instance.visible = false
	instance.set_process(false)
	instance.set_physics_process(false)
	if instance.has_method("on_returned_to_pool"):
		instance.on_returned_to_pool()
