@tool
extends EditorPlugin

const CONFIG_KEY: String = "application/config/object_pool_settings"

func _enter_tree() -> void:		
	var value = ProjectSettings.get_setting(CONFIG_KEY, "")
	if value is String and !value.is_empty() and ResourceLoader.exists(value):
		ProjectSettings.set_setting(CONFIG_KEY, load(value))

func _enable_plugin() -> void:
	if !ProjectSettings.has_setting(CONFIG_KEY):
		ProjectSettings.set_setting(CONFIG_KEY, "")
		ProjectSettings.set_as_basic(CONFIG_KEY, true)
	
	ProjectSettings.add_property_info({
		"name": CONFIG_KEY,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "ObjectPoolSettings"
	})
	
	add_autoload_singleton("ObjectPoolManager", "res://addons/ObjectPool/ObjectPoolManager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("ObjectPoolManager")

func _save_external_data() -> void:
	var res = ProjectSettings.get_setting(CONFIG_KEY, null)
	if res is ObjectPoolSettings:
		ProjectSettings.set_setting(CONFIG_KEY, res.resource_path)
		ProjectSettings.save()
