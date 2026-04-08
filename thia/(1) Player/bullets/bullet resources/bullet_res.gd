class_name Bullet_Res

extends Resource

@export var bullet_name: String          = "unknown"
@export var mov_speed: float             = 225.0
@export var dmg_multiplier: float        = 1.0

@export var col_Shape: Shape2D
@export var sprite_texture: Texture
@export var onDestroy_effName: String    = "basic"

@export var b_bonus_dmg: float           = 0.0

@export var base_mov_Dir : Vector2       = Vector2.RIGHT

@export var amount_InPool: int           = 20
