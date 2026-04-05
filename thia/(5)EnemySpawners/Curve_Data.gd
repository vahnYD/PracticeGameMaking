# Curve_Data.gd
class_name CurveData
extends Resource

@export var curve_shape : Curve
@export var curve_type: GlobalTypes.curve_types
@export var curve_name: String

## affect how fast the curve is, lower value means faster curve reading
@export_range(0.1,5.0,0.1) var curve_duration: float = 2.0
