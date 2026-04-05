class_name SummonConfig
extends Resource

@export var minionName: String = ""
@export var enemy_count: int = 1
@export var summon_interval: float = 0.1

## use simple ZigZag, or a Curve.
@export var use_basicmovesetting: bool = true
@export var spawnBox_basicspeed: float = 400.0
@export var spawnBox_initialmoveVector: Vector2 = Vector2.ZERO:
	get:
		return spawnBox_initialmoveVector
	set(value):
		spawnBox_initialmoveVector = Vector2(sign(value.x), sign(value.y))

@export var wave_size: float = 256.0:
	get:
		return wave_size
	set(value):
		wave_size = clamp(value,0,1080.0)
		
@export var isSpin: int = 0:
	get:
		return isSpin
	set(value):
		isSpin = clampi(value, -1,1)
@export var spin_speed: float = 0.0
@export var spawnBox_initialPos: Vector2 = Vector2.ZERO 
			# used to summon the spawnBox at either side of the wave, 
			#  rather than thecenter. 

## keeps data of the Curve shape, curve_name (for calls), and initial_readType (pingpong or fmod)
## pingpong means curve goes left to right then right to left, fmod means left to right and teleports back to
## value 0.0 upon hitting max value
@export var wave_curve_data: WaveCurveData

## start curve from the right, instead of from the left (usually 0,0)
@export var movCurveFlip: bool = false

## start a Curve Wave at beginning, up to at the end
@export var WaveCurve_startAt: float = 0.0:
	get:
		return WaveCurve_startAt
	set(value):
		WaveCurve_startAt = clamp(value,0,1.0)
@export var WaveCurveDuration: float = 2.0: ## lower number means faster curve speed
	get:
		return WaveCurveDuration
	set(value):
		WaveCurveDuration = clampf(value,0.1,9.0)

## freeze Enemy for X seconds
@export var freezeTime: float = 0.0
@export var movTypeOverCheck : bool
@export var MoveTypeOverride: global_enums.Minion_moveType

@export var onSpawnFunc: Callable
@export var minion_MoveDirOverride: Callable
	
	# isSpin 1 = go clockwise (from right to down), -1 reverse that.
