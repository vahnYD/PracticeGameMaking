# Enemy_Spawner_Box.gd
@tool
class_name EnemySpawnerBox
extends Node2D


@onready var spawnerIndicator: Sprite2D = $spawnerIndicator

@export var init_param: SpawnParam:
	set (value):
		_load_from_param(value)
		notify_property_list_changed()
		


## most of the bigger number (past 8) is mainly used for circle-shaped spawns
@export_range(1,36,1) var spawnBoxCount : int = 1

@export_enum("followBG","static") var spawner_type: String = "followBG":
	set(value):
		spawner_type = value
		_update_editor_visuals()
		notify_property_list_changed()

@onready var staticActTimer: Timer = $staticActTimer
@export var staticTime: float = 0.05

@export_enum("Miteo", "Virus") var enemy_name: String
@export_range(1,300, 1) var enemy_amount: int = 10
@export_range(0.1, 6.0, 0.01) var spawn_interval: float = 0.2

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

@export_range(0.0, 1400.0, 1.0) var curve_waveLength: float = 512.0 

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

## moving the spawner itself in a vector direction once its activated.
@export var spawner_movVector : Vector2 = Vector2.ZERO

## is active means currently, actively spawning enemies.
var is_active: bool = false
var enemy_spawnPoses: Array[Vector2]

var time: float = 0.0
var curve_progress: float = 0.0
var curve_cur_value: float

var spawnPosBoxes : Dictionary = {}
var homingTarget: PlayerCharacter
var screensize: Vector2

func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("curve_") and param_type != "curve":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name.begins_with("spin_") and param_type != "spin":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _update_editor_visuals():
	if gameStart == false and spawnerIndicator != null:
		match spawner_type:
			"followBG":
				spawnerIndicator.modulate = Color.CYAN
			"static":
				spawnerIndicator.modulate = Color.ORANGE


signal get_enemy_data(Node, enemy_name, onSpawnFunc: Callable, mov_override: Callable, veerStr: float)

var cur_enemy_data: EnemyScaledData
var slide_speed: float = 0.0
var gameStart: bool = false

func activate_spawner():
	if spawner_type == "followBG":
		# back the spawner a bit to make space for the spawning
		if param_type == "spin":
			global_position.x += spin_initPos.length() + 64.0 
		if param_type == "curve":
			global_position.x += 333.0
	if param_type == "curve":
		setup_spawnerboxes_curve(spawnBoxCount)
	elif  param_type == "spin":
		setup_spawnerboxes_spin(spawnBoxCount)
	is_active = true
	
func deactivate_spawner():
	is_active = false
	set_process(false)
	set_physics_process(false)
	
func _load_from_param(p: SpawnParam) -> void:
	spawnBoxCount  = p.spawnBoxCount
	enemy_name     = p.enemy_name
	enemy_amount   = p.enemy_amount
	spawn_interval = p.spawn_interval
	param_type     = p.param_type
	

	# Curve params
	curve_used       = p.curve_used
	curve_init_time  = p.curve_init_time
	curve_type       = p.curve_type
	curve_flip       = p.curve_flip
	curve_waveLength = p.curve_waveLength
	curve_dur        = p.curve_dur
	curve_UpDown     = p.curve_UpDown
	curve_RightLeft  = p.curve_RightLeft

	# Spin params
	spin_initPos = p.spin_initPos
	spin_dir     = p.spin_dir
	spin_speed   = p.spin_speed

	# Override params
	mov_override_name     = p.mov_override_name
	mov_override_dur      = p.mov_override_dur
	mov_overrideStr       = p.mov_overrideStr
	
	spawner_movVector     = p.spawner_movVector


func _ready():
	call_deferred("_update_editor_visuals")


func start_game():
	await get_tree().process_frame
	gameStart = true
	screensize = GameManager.viewport_size
	spawnerIndicator.visible = false
	if spawner_type == "static":
		staticActTimer.start(staticTime)


var spawn_cooldown: float = 0.0
func _process(delta):
	if gameStart and not is_active:
		if spawner_type == "followBG":
			global_position += Vector2.LEFT * slide_speed * delta
			# spawner only moves if its not active and type followBG, once its activated, it stays on screen.

	if not is_active or cur_enemy_data == null:
		return
		
	global_position += spawner_movVector * delta
	
	if param_type == "curve":
		time += delta
		for key in spawnPosBoxes:
			#key is number from 0 to spawnboxes.enemy_amount - 1
			var data = spawnPosBoxes[key]
			curve_movement(delta,data["spawnbox"], data["pos"])
	if param_type == "spin":
		for key in spawnPosBoxes:
			#key is number from 0 to spawnboxes.enemy_amount - 1
			var data = spawnPosBoxes[key]
			spin_movement(delta,data["spawnbox"])
		
	spawn_cooldown += delta
	if spawn_cooldown > spawn_interval and enemy_amount > 0:
		spawn_cooldown -= spawn_interval
		for each in spawnPosBoxes.size():
			enemy_amount -= 1
			var pos: Vector2 = enemy_spawnPoses.pop_back()
			EnemyPool.put_enemy_toGame(cur_enemy_data,pos)
	if enemy_amount <= 0:
		deactivate_spawner()


func curve_movement(_delta, spawnbox : Marker2D, init_progress: float ):
	var _spec_time : float = time + (init_progress * curve_dur)
	var _curve_progress: float
	var _curve_cur_value : float
	if curve_type == GlobalTypes.curve_types.fmod:
		_curve_progress = fmod(_spec_time,curve_dur) / curve_dur
	elif curve_type == GlobalTypes.curve_types.ping_pong:
		_curve_progress = pingpong(_spec_time,curve_dur) / curve_dur
	_curve_cur_value = curve_used.sample(_curve_progress)
	if curve_flip:
		_curve_cur_value = 1 - _curve_cur_value 
	if curve_UpDown == true:
		spawnbox.position.y = lerp(-curve_waveLength, curve_waveLength, _curve_cur_value)
	if curve_RightLeft == true:
		spawnbox.position.x = lerp(curve_waveLength, -curve_waveLength, _curve_cur_value)
	if spawn_cooldown >= 0.01 : 
		# only put the position if enemies are about to be spawned. so that the array isn't filled with junk values
		# there is a safeguard of 0.01s
		enemy_spawnPoses.append(spawnbox.global_position)


func spin_movement(_delta, spawnbox : Marker2D):
	rotation_degrees += _delta * spin_speed * spin_dir
	if spawn_cooldown >= 0.01 : 
		enemy_spawnPoses.append(spawnbox.global_position)


func grab_enemy_data():
	var _mov_override: Callable = Callable()
	var onSpawnFunc: Callable = Callable()
	match mov_override_name:
		"freeze":
			## freeze enemy for a period in the timer.
			onSpawnFunc = func(en : Enemy):
				var saveMS :float = en.move_spd
				en.move_spd = 0.0
				var _tween : Tween = create_tween()
				_tween.tween_property(en,"move_spd",saveMS,en.move_overrideDur)\
				.set_ease(Tween.EASE_IN)\
				.set_trans(Tween.TRANS_EXPO)
				
		"seek":
			## apply the veer, gradually reducing in strength as long as override_VeerStr > 0
			_mov_override = func(en : Enemy, _delta):
				en.override_VeerStr -= _delta * 0.33
				if en.override_VeerStr > 0:
					en.move_dir += en.global_position.direction_to(homingTarget.global_position) * en.override_VeerStr
		
		"randomize":
			## apply the veer, gradually reducing in strength as long as override_VeerStr > 0
			_mov_override = func(en : Enemy, delta):
				# custom value means whatever data necessary for the indended movement override, 
				# in this case, random mov coldown
				en.override_CustomValue += delta 
				 # slowly return the movement to normal
				if en.override_CustomValue > 0.35:
					en.override_CustomValue = 0
					if en.override_VeerStr > 0:
						en.override_VeerStr -= delta * 0.133
						en.move_OverrideDir = Vector2(randf_range(-1,1),randf_range(-1,1)) * en.override_VeerStr
		
		"to_Ycenter":
			## go to screen center, just the Y. for spawners on the top and bottom of the screen, mostly.
			onSpawnFunc = func(en : Enemy):
				## feer strength is not weakened over time for this.
				if en.global_position.y > screensize.y/2 : # below screen center
					if en.override_VeerStr > 0:
						en.move_OverrideDir = Vector2.UP * en.override_VeerStr
				elif en.global_position.y < screensize.y/2 : # above screen center
					if en.override_VeerStr > 0:
						en.move_OverrideDir = Vector2.DOWN * en.override_VeerStr
		
		"follow_spin":
			var spawner_ref := self				
			_mov_override = func(en : Enemy, _delta):
				if en.override_VeerStr > 0:
					var progress = 1.0 - (en.move_overrideDur / en.move_overrideDurMax)
					# gets move override weaker depending on progress. also, apparently with \, you can make a new line
					en.move_OverrideDir = spawner_ref.global_position.direction_to(en.global_position)\
					* en.override_VeerStr * (1 - progress)
					
		"orbit":
			var spawner_ref := self
			_mov_override = func(en : Enemy, _delta):
				var to_enemy = spawner_ref.global_position.direction_to(en.global_position)
				var tangent = to_enemy.rotated(PI/2 * spawner_ref.spin_dir)
				en.move_OverrideDir = tangent * en.override_VeerStr
				
		"inward_spiral":
			var spawner_ref := self
			_mov_override = func(en : Enemy, _delta):
				var to_center = en.global_position.direction_to(spawner_ref.global_position)
				var tangent = to_center.rotated(PI/2 * spawner_ref.spin_dir)
				en.move_OverrideDir = (to_center + tangent) * en.override_VeerStr
		
		"out_in_spiral":
			var spawner_ref := self
			onSpawnFunc = func(en : Enemy):
				en.override_CustomValue = en.move_overrideDur
				
			_mov_override = func(en : Enemy, delta):
				if en.override_VeerStr > 0:
					en.override_CustomValue -= delta * 1.9
					var progress = 1.0 - (en.override_CustomValue / en.move_overrideDur)
					# apparently with \, you can make a new line
					en.move_OverrideDir = spawner_ref.global_position.direction_to(en.global_position)\
					* en.override_VeerStr * (1 - progress)

	get_enemy_data.emit(self,enemy_name, onSpawnFunc,_mov_override, mov_override_dur, mov_overrideStr)

func setup_spawnerboxes_spin(spawnerAmount: int):
	if spawnerAmount == 1:
		var newSpawnPosBox : Marker2D = Marker2D.new()
		add_child(newSpawnPosBox)
		newSpawnPosBox.position = spin_initPos
		spawnPosBoxes[0] = {
			"spawnbox": newSpawnPosBox, "pos": spin_initPos }
	if spawnerAmount > 1:
		var radius:float = spin_initPos.length()
		var init_angle: float = spin_initPos.angle()
		for count in range(spawnerAmount):                                            # for each spawner amount
			var newSpawnPosBox : Marker2D = Marker2D.new()                            # make a new spawner
			add_child(newSpawnPosBox)                                                 # add it as the child of the node
			var angle :float = init_angle + (TAU / spawnerAmount) * count             # get angle, split evenly per spawners
			newSpawnPosBox.position = Vector2(cos(angle), sin(angle)) * radius        # set the position
			spawnPosBoxes[count] = {
				"spawnbox": newSpawnPosBox, "pos": newSpawnPosBox.position }          # log it in

		
func setup_spawnerboxes_curve(spawnerAmount: int):
	if spawnerAmount == 1: # if only 1 spawner, just use curve_init time
		var newSpawnPosBox : Marker2D = Marker2D.new()
		add_child(newSpawnPosBox)
		newSpawnPosBox.position = Vector2.ZERO
		spawnPosBoxes[0] = {
			"spawnbox": newSpawnPosBox, "pos": curve_init_time }
			
	if spawnerAmount > 1:
		for count in range(spawnerAmount):
			#var newSpawnPosBox : Sprite2D = init_spawnPosBox.duplicate()
			var newSpawnPosBox : Marker2D = Marker2D.new()
			add_child(newSpawnPosBox)
			newSpawnPosBox.position = Vector2.ZERO
			newSpawnPosBox.global_position = global_position
			## to give an example of how the math works... say there's 4 spawnerAmount. ( will loop 4 times)
			## loop 1, count = 0, thus newPos                = 0
			## loop 2, count = 1, thus newpos = 1 / ( 4 - 1 ) = 0.333
			## loop 3, count = 2, thus newpos = 2 / ( 4 - 1 ) = 0.666
			## loop 4, count = 3, thus newpos = 3 / ( 4 - 1 ) = 1.0
			var newPos = count / float(spawnerAmount - 1) 
			
			spawnPosBoxes[count] = {
					"spawnbox": newSpawnPosBox, "pos": newPos}
		

func _on_visible_on_screen_notifier_2d_screen_entered():
	if spawner_type == "followBG":
		grab_enemy_data()


func _on_static_act_timer_timeout():
	if spawner_type == "static":
		grab_enemy_data()
