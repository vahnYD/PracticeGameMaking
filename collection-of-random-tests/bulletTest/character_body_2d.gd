extends CharacterBody2D

@export var bullet: PackedScene

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		var bullet_Instance = bullet.instantiate()
		if Input.is_action_pressed("ui_left"):
			bullet_Instance.speed += 800

		
		add_child(bullet_Instance)
