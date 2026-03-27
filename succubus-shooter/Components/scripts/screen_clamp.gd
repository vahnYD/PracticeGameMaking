extends Node
class_name ScreenClampHelper

##this is marked as AI-creation that i dont understand, i will not be using this


const SCREEN_MARGIN: float = 20.0

func clamp_node_to_screen(target: Node2D, half_size: Vector2 = Vector2(50, 10)):
	var viewport_rect = target.get_viewport_rect()
	var screen_min = viewport_rect.position + Vector2(SCREEN_MARGIN, SCREEN_MARGIN)
	var screen_max = viewport_rect.end - Vector2(SCREEN_MARGIN, SCREEN_MARGIN)

	var screen_pos = world_to_screen(target, target.global_position)

	var clamped = Vector2(
		clamp(screen_pos.x, screen_min.x + half_size.x, screen_max.x - half_size.x),
		clamp(screen_pos.y, screen_min.y + half_size.y, screen_max.y - half_size.y)
	)

	target.global_position = screen_to_world(target, clamped)

func clamp_position_to_screen(target: Node2D, desired_world_pos: Vector2, half_size: Vector2 = Vector2(50, 10)) -> Vector2:
	var viewport_rect = target.get_viewport_rect()
	var screen_min = viewport_rect.position + Vector2(SCREEN_MARGIN, SCREEN_MARGIN)
	var screen_max = viewport_rect.end - Vector2(SCREEN_MARGIN, SCREEN_MARGIN)

	var screen_pos = world_to_screen(target, desired_world_pos)

	var clamped = Vector2(
		clamp(screen_pos.x, screen_min.x + half_size.x, screen_max.x - half_size.x),
		clamp(screen_pos.y, screen_min.y + half_size.y, screen_max.y - half_size.y)
	)

	return screen_to_world(target, clamped)

func world_to_screen(node: Node2D, world_pos: Vector2) -> Vector2:
	var camera = node.get_viewport().get_camera_2d()
	if camera:
		return world_pos - camera.global_position + node.get_viewport_rect().size / 2.0
	return world_pos

func screen_to_world(node: Node2D, screen_pos: Vector2) -> Vector2:
	var camera = node.get_viewport().get_camera_2d()
	if camera:
		return screen_pos + camera.global_position - node.get_viewport_rect().size / 2.0
	return screen_pos
