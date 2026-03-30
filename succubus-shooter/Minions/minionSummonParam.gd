class_name SummonConfig
extends Resource

@export var minionName: String = ""
@export var enemy_count: int = 1
@export var summonInterval: float = 0.1

## use simple ZigZag, or a Curve.
@export var useBasicMovSet: bool = true
@export var spawnerMoveSpeed: float = 400.0
@export var initialMovVector: Vector2 = Vector2.ZERO:
	get:
		return initialMovVector
	set(value):
		initialMovVector = Vector2(sign(value.x), sign(value.y))

@export var waveSize: float = 256.0:
	get:
		return waveSize
	set(value):
		waveSize = clamp(value,0,1080.0)
		
@export var isSpin: int = 0:
	get:
		return isSpin
	set(value):
		isSpin = clampi(value, -1,1)
@export var spinSpeed: float = 0.0
@export var initialPos: Vector2 = Vector2.ZERO 
			# used to summon the spawnBox at either side of the wave, 
			#  rather than thecenter. 

## keeps data of the Curve shape, curve_name (for calls), and initial_readType (pingpong or fmod)
## pingpong means curve goes left to right then right to left, fmod means left to right and teleports back to
## value 0.0 upon hitting max value
@export var movementCurve: WaveCurveData
@export var movCurveFlip: bool = false

## start a Curve Wave at beginning, up to at the end
@export var start_at: float = 0.0:
	get:
		return start_at
	set(value):
		start_at = clamp(value,0,1.0)
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
@export var movDirOverride: Callable
	
	# isSpin 1 = go clockwise (from right to down), -1 reverse that.
