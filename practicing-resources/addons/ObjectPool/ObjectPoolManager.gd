extends Node

@export var _active_pool_settings: Dictionary[Node, PooledNodeSettings] = {}
var active_pool_settings: Dictionary[Node, PooledNodeSettings]:
	get: return _active_pool_settings

var settings: ObjectPoolSettings

func _ready() -> void:
	var path = ProjectSettings.get_setting("application/config/object_pool_settings")
	if not path:
		push_error("[ObjectPool] ObjectPoolSettings not found at path: " + str(path))
		return
	settings = load(path) as ObjectPoolSettings
	
	for scene: PackedScene in settings.initial_nodes_to_pool:
		var pool_settings: PooledNodeSettings = settings.initial_nodes_to_pool[scene]
		var node: Node = scene.instantiate()
		if !add_node_type(node, pool_settings):
			push_error("[ObjectPool] Failed to spawn initial count of node class \"%s\"" % scene.resource_path if scene != null else "Unknown class")

func _exit_tree() -> void:
	if !settings || !settings.destroy_on_end:
		return
	
	for node_class: IObjectPooledNode in pool:
		var bucket: PoolBucket = pool[node_class]
		
		for active_node: IObjectPooledNode in bucket.active:
			if is_instance_valid(active_node):
				active_node.queue_free()
		
		for inactive_node: IObjectPooledNode in bucket.inactive:
			if is_instance_valid(inactive_node):
				inactive_node.queue_free()
		
	
func spawn_new_node(node: IObjectPooledNode) -> IObjectPooledNode:
	if !is_instance_valid(node):
		push_error("[ObjectPool] Failed to spawn node of class \"%s\"" % node.resource_path)
		return null
	
	add_child(node)
	node.hide()
	return node

func push(node: IObjectPooledNode) -> bool:
	if !is_instance_valid(node) || !ClassDB.is_parent_class(node.get_instance_base_type(), "IObjectPooledNode"):
		return false
	
	if !pool.has(node):
		if !add_node_type(node, PooledNodeSettings.new()):
			push_error("[ObjectPool] Pushed actor of type \"%s\" did not already exist in pool and could not be added either" % node.resource_path)
			return false
		
		if !pool.has(node):
			return false
			
	var subpools: PoolBucket = pool.find_key(node)
	subpools.active.erase(node)
	subpools.inactive.append(node)
	node.on_pushed_to_pool()
	return true

func pull(node: IObjectPooledNode, node_out: Node) -> bool:
	var subpool: PoolBucket = pool.find_key(node)
	if !subpool:
		if !add_node_type(node, PooledNodeSettings.new()):
			push_error("[ObjectPool] Pushed actor of type \"%s\" did not already exist in pool and could not be added either" % node.resource_path)
			return false

		subpool = pool.find_key(node)
		if !subpool:
			push_error("[ObjectPool] Could not find subpool even after adding node type")
			return false
	
	var pulled_node: IObjectPooledNode = null
	
	# inactive pool
	for element: IObjectPooledNode in subpool.inactive:
		if is_instance_valid(element):
			pulled_node = element
			node_out = pulled_node
			subpool.remove(pulled_node)
			break
	
	if is_instance_valid(pulled_node):
		subpool.active.append(pulled_node)
		pulled_node.on_pulled_from_pool()
		node_out = pulled_node
		return true
	else:
		var settings: PooledNodeSettings = active_pool_settings.get(node)
		if settings && settings.can_expand_if_needed:
			pulled_node = spawn_new_node(node)
			if !is_instance_valid(pulled_node):
				return false
			
			subpool.active.append(pulled_node)
			pulled_node.on_pulled_from_pool()
			node_out = pulled_node
			return true
		return false
	
	
func add_node_type(node: Node, node_settings: PooledNodeSettings) -> bool:
	if !is_instance_valid(node):
		return false
	
	if !ClassDB.is_parent_class(node.get_instance_base_type(), "IObjectPooledNode"):
		push_error("[ObjectPool] The node \"%s\" does not extend the \"IObjectPooledNode\" interface", [node.resource_path])
		return false
		
	if pool.has(node):
		return false
		
	var inactive_pool: Array[IObjectPooledNode]
	_active_pool_settings.set(node, node_settings)
	for i in node_settings.initial_spawn_count:
		var new_node: IObjectPooledNode = spawn_new_node(node)
		if !is_instance_valid(new_node):
			push_error("[ObjectPool] add_node_type() failed to spawn new node")
			continue
			
		inactive_pool.append(new_node)
		new_node.on_pushed_to_pool()
	var bucket := PoolBucket.new()
	bucket.inactive = inactive_pool
	return true
	
class PoolBucket:
	var active: Array[IObjectPooledNode] = []
	var inactive: Array[IObjectPooledNode] = []
	
	func all() -> Array[IObjectPooledNode]:
		return active + inactive
	
	func remove(node: IObjectPooledNode) -> void:
		if inactive.has(node):
			inactive.erase(node)
		else:
			active.erase(node)
	
# Tuple Key = Active pool, Tuple Value = Inactive pool
var pool: Dictionary[IObjectPooledNode, PoolBucket] = {}
