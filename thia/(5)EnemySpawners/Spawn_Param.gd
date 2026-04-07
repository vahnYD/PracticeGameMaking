@tool
class_name SpawnParam
extends Resource

@export_range(1,24,1) var spawnBoxCount : int = 1

@export_enum("followBG","static") var spawner_type: String = "followBG"
		
@export var staticTime: float = 0.05

@export_enum("Miteo", "Virus") var enemy_name: String
@export_range(1,300, 1) var enemy_amount: int = 10
@export_range(0.1, 3.0, 0.01) var spawn_interval: float = 0.2

@export_enum("curve","spin") var param_type : String = "curve":
	set (value):
		param_type = value
		notify_property_list_changed()


#region curve parameters
@export var curve_used : Curve

@export var curve_UpDown: bool = true
@export var curve_RightLeft: bool = false

## set to 1 in order to start the Curve at the end.
@export_range(0.0,1.0, 0.1) var curve_init_time: float = 0.0

@export var curve_type : GlobalTypes.curve_types = GlobalTypes.curve_types.ping_pong
@export var curve_flip : bool = false

@export_range(0.0, 1100.0, 1.0) var curve_waveLength: float = 512.0 

## lower value means faster, default amount is 2.0
@export_range(0.1, 40.0, 0.1) var curve_dur: float = 2.0

#endregion

#region spin parameters
## is also the radius of the circle
@export var spin_initPos : Vector2 = Vector2(256.0,256.0)
@export_enum("clockwise:1","counter clockwise:-1") var spin_dir: int = 1
@export_range(0.1, 400.0, 0.1) var spin_speed: float = 200.0
#endregion


#region move override params

@export_enum("none","freeze","seek","randomize","to_Ycenter","follow_spin","orbit","inward_spiral","out_in_spiral") var mov_override_name: String = "none"
@export_range(0.0,25.0,0.1) var mov_override_dur: float = 0.0
@export_range(0.0,12.0,0.1) var mov_overrideStr: float = 0.0
#endregion


func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("curve_") and param_type != "curve":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name.begins_with("spin_") and param_type != "spin":
		property.usage = PROPERTY_USAGE_NO_EDITOR
