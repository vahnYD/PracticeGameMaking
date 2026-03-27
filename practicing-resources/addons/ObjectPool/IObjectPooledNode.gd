class_name IObjectPooledNode
extends Node

func on_pushed_to_pool() -> void:
	push_error("[ObjectPool] Pure virtual not implemented (%s::%s)" % [get_path(), "on_pushed_to_pool"])
	
func on_pulled_from_pool() -> void:
	push_error("[ObjectPool] Pure virtual not implemented (%s::%s)" % [get_path(), "on_pulled_from_pool"])
	
func hide() -> void:
	push_error("[ObjectPool] Pure virtual not implemented (%s::%s)" % [get_path(), "hide"])

func show() -> void:
	push_error("[ObjectPool] Pure virtual not implemented (%s::%s)" % [get_path(), "show"])
