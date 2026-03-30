class_name WaveCurveData
extends Resource

@export var curve_name: String = ""
@export var curve: Curve
@export var initial_cycleDuration: float = 2.0
@export var initial_readType: readtype = readtype.pingpong
	
enum readtype{
	fmod,
	pingpong
}
