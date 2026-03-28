@tool
class_name BulletResource
extends Resource

## Packed scene containing the bullet
@export var SpecificBulletScene: PackedScene

#base values of bullet:
@export var bullet_name: String = "Default bullet"
@export var damage_multiplier: float = 1.0
@export var speed: float = 400.0
@export var ability: Ability_list = Ability_list.None:
	set(value):
		ability = value
		notify_property_list_changed()
@export var onDestroyScene: PackedScene = null
@export var unloadTimerValue: float = 2.0
@export var bulletPoolAmount: int = 50

enum Ability_list{
	None,
	Piercing,
	WeakPiercing,
	Exploding,
	Execution, # chance to SuperCrit, dealing an extremely high dmg
	Lifesteal
}



# ==========================================
# ABILITY SPECIFIC STATS
# Note: Keep the prefixes strictly matching the names in _validate_property!
# ==========================================

#weakPiercing variables
@export var weakPiercing_DmgDropoffPercent: float = 30.0
@export var weakPiercing_maxPierceCount: int = 3

# Lifesteal variables
@export var lifesteal_chance: float = 10.0
@export var lifesteal_heal: float = 3.0

# Execution variables
@export var execution_chance: float = 2.0
@export var execution_multiplier: float = 7.0

# Exploding variables (example)
@export var exploding_radius: float = 64.0
@export var exploding_dmgMultiplier: float = 0.50


# ==========================================
# EDITOR LOGIC (Zero performance cost in-game)
# ==========================================
func _validate_property(property: Dictionary) -> void:
	# If the variable name starts with "lifesteal_" but the ability ISN'T Lifesteal, hide it.
	if property.name.begins_with("weakPiercing_") and ability != Ability_list.WeakPiercing:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	elif property.name.begins_with("lifesteal_") and ability != Ability_list.Lifesteal:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	# Do the same for execution
	elif property.name.begins_with("execution_") and ability != Ability_list.Execution:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	# And exploding
	elif property.name.begins_with("exploding_") and ability != Ability_list.Exploding:
		property.usage = PROPERTY_USAGE_NO_EDITOR
