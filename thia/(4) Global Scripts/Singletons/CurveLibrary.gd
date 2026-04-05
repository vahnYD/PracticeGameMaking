# CurveLibrary.gd, this one is a Singleton
extends Node
var curve_ease: CurveData
var curve_riseUp: CurveData
var curve_chaotic: CurveData

# or store them in a dict for dynamic lookup
var all_curves: Dictionary = {}

func _ready() -> void:
	# Load each curve resource by path
	curve_ease   = load("res://(4) Global Scripts/curves/curve_ease.tres")
	curve_riseUp = load("res://(4) Global Scripts/curves/curve_riseUp.tres")
	curve_chaotic = load("res://(4) Global Scripts/curves/curve_chaotic.tres")
	
	# Mirror into dict for easy iteration / lookup by name
	all_curves = {
		"curve_ease":    curve_ease,
		"curve_riseUp":  curve_riseUp,
		"curve_chaotic": curve_chaotic,
	}
