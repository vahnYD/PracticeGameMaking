# Global_Enums.gd
class_name GlobalTypes
extends RefCounted

enum enemy_move_types {
	straight,
	wavy,
	homing
}

## either fmod or ping_pong
enum curve_types {
	fmod,
	ping_pong
}
