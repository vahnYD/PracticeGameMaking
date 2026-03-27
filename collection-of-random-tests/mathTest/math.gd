extends Node2D


var float_array: Array[float]
var baseMoveSpeed: float = 235
var curMoveSpeed: float
var curChange: float

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#print("Left mouse button was clicked!")
			# Add your custom logic here
			

func _ready():
	$Label.text = str(baseMoveSpeed)
	curMoveSpeed = baseMoveSpeed

func _on_button_pressed():
	movespeedChange()
	curMoveSpeed = curMoveSpeed * (1 + curChange/100)
	$Label.text = "Move Speed changed by " + str(curChange) + "%; and now becomes : " + str(curMoveSpeed)
	await get_tree().create_timer(3).timeout
	
	curMoveSpeed = curMoveSpeed / (1 + float_array.pop_front()/100)
	$Label.text = "Move Speed reverted. And now becomes : " + str(curMoveSpeed)

func movespeedChange():
	curChange = snapped(randf_range(-30,30), 0.01) 
	float_array += [curChange]
	
	
func get_current_speed() -> float:
	# reduce() starts with base_speed, and multiplies it by (1.0 + mod) for every item in the array
	return float_array.reduce(func(accum, mod): return accum * (1.0 + mod), baseMoveSpeed)	
	
	
	
