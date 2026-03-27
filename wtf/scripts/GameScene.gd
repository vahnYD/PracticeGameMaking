# GameScene.gd
# Main game scene controller. Attach to the root Node2D of your game scene.
# Manages: level loading, UI, player-enemy collision, win/lose/transition.
extends Node2D

# State enum
enum State { MENU, PLAYING, LEVEL_COMPLETE, GAME_OVER }
var state: State = State.MENU

var current_level_index: int = 0
var all_levels: Array = []
var current_level: LevelData = null
var level_elapsed: float = 0.0

# Node refs (built procedurally — replace with $NodePath if using the editor)
var player: Player = null
var spawn_manager: SpawnManager = null
var bg_rect: ColorRect = null
var bg_tile_container: Node2D = null
var ui_layer: CanvasLayer = null

# UI labels
var lbl_time: Label = null
var lbl_health: Label = null
var lbl_xp: Label = null
var lbl_level: Label = null
var lbl_wave_phase: Label = null
var lbl_overlay: Label = null
var btn_overlay: Button = null
var bar_health: ColorRect = null
var bar_health_bg: ColorRect = null
var bar_xp: ColorRect = null
var bar_xp_bg: ColorRect = null

const DAMAGE_TICK_INTERVAL: float = 0.5
var _damage_timer: float = 0.0

func _ready() -> void:
	all_levels = LevelData.get_all()
	_build_scene()
	_show_menu()

# ---- SCENE CONSTRUCTION ----

func _build_scene() -> void:
	# Background
	bg_rect = ColorRect.new()
	bg_rect.size = get_viewport().get_visible_rect().size
	bg_rect.color = Color(0.05, 0.05, 0.05)
	add_child(bg_rect)

	bg_tile_container = Node2D.new()
	add_child(bg_tile_container)

	# Player
	#player = CharacterBody2D.new()
	player.add_child(CharacterBody2D.new())
	player.set_script(load("res://scripts/Player.gd"))
	player.add_to_group("player")
	add_child(player)
	player.global_position = get_viewport().get_visible_rect().size / 2.0
	player.health_changed.connect(_on_player_health_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	player.level_changed.connect(_on_player_level_changed)
	player.died.connect(_on_player_died)

	# SpawnManager
	spawn_manager = SpawnManager.new()
	spawn_manager.set_script(load("res://scripts/SpawnManager.gd"))
	add_child(spawn_manager)

	# UI
	_build_ui()

func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	var vp = get_viewport().get_visible_rect()
	var W = vp.size.x

	# Health bar bg
	bar_health_bg = ColorRect.new()
	bar_health_bg.color = Color(0.3, 0.0, 0.0)
	bar_health_bg.size = Vector2(200, 16)
	bar_health_bg.position = Vector2(10, 10)
	ui_layer.add_child(bar_health_bg)

	bar_health = ColorRect.new()
	bar_health.color = Color(0.9, 0.1, 0.1)
	bar_health.size = Vector2(200, 16)
	bar_health.position = Vector2(10, 10)
	ui_layer.add_child(bar_health)

	lbl_health = Label.new()
	lbl_health.text = "HP: 100/100"
	lbl_health.position = Vector2(10, 28)
	lbl_health.add_theme_font_size_override("font_size", 12)
	ui_layer.add_child(lbl_health)

	# XP bar
	bar_xp_bg = ColorRect.new()
	bar_xp_bg.color = Color(0.1, 0.1, 0.3)
	bar_xp_bg.size = Vector2(200, 10)
	bar_xp_bg.position = Vector2(10, 46)
	ui_layer.add_child(bar_xp_bg)

	bar_xp = ColorRect.new()
	bar_xp.color = Color(0.3, 0.5, 1.0)
	bar_xp.size = Vector2(0, 10)
	bar_xp.position = Vector2(10, 46)
	ui_layer.add_child(bar_xp)

	lbl_xp = Label.new()
	lbl_xp.text = "XP: 0 / 10"
	lbl_xp.position = Vector2(10, 58)
	lbl_xp.add_theme_font_size_override("font_size", 12)
	ui_layer.add_child(lbl_xp)

	lbl_level = Label.new()
	lbl_level.text = "Lv.1"
	lbl_level.position = Vector2(215, 10)
	lbl_level.add_theme_font_size_override("font_size", 18)
	ui_layer.add_child(lbl_level)

	lbl_time = Label.new()
	lbl_time.text = "0:00 / 2:00"
	lbl_time.position = Vector2(W / 2.0 - 60, 10)
	lbl_time.add_theme_font_size_override("font_size", 18)
	ui_layer.add_child(lbl_time)

	lbl_wave_phase = Label.new()
	lbl_wave_phase.text = ""
	lbl_wave_phase.position = Vector2(W / 2.0 - 80, 36)
	lbl_wave_phase.add_theme_font_size_override("font_size", 12)
	ui_layer.add_child(lbl_wave_phase)

	# Overlay (menu / game over / win)
	var overlay_bg = ColorRect.new()
	overlay_bg.color = Color(0, 0, 0, 0.7)
	overlay_bg.size = get_viewport().get_visible_rect().size
	overlay_bg.position = Vector2.ZERO
	overlay_bg.name = "OverlayBG"
	ui_layer.add_child(overlay_bg)

	lbl_overlay = Label.new()
	lbl_overlay.position = Vector2(W / 2.0 - 180, 160)
	lbl_overlay.size = Vector2(360, 200)
	lbl_overlay.add_theme_font_size_override("font_size", 28)
	lbl_overlay.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_layer.add_child(lbl_overlay)

	btn_overlay = Button.new()
	btn_overlay.size = Vector2(200, 44)
	btn_overlay.position = Vector2(W / 2.0 - 100, 340)
	btn_overlay.add_theme_font_size_override("font_size", 18)
	ui_layer.add_child(btn_overlay)
	btn_overlay.pressed.connect(_on_overlay_btn_pressed)

	# Toggle overlay visibility
	overlay_bg.visible = false
	lbl_overlay.visible = false
	btn_overlay.visible = false

# ---- STATE MACHINE ----

func _show_menu() -> void:
	state = State.MENU
	_set_overlay(true, "VAMPIRE SURVIVORS\n\nArrow Keys: Move\nAuto-attack nearby enemies", "Start Level 1")
	_clear_enemies()

func _start_level(level_index: int) -> void:
	current_level_index = level_index
	current_level = all_levels[level_index]
	level_elapsed = 0.0
	state = State.PLAYING

	# Apply BG
	bg_rect.color = current_level.bg_color
	_rebuild_bg_tiles(current_level)

	# Reset player
	player.health = player.max_health
	player.global_position = get_viewport().get_visible_rect().size / 2.0
	_on_player_health_changed(player.health, player.max_health)

	# Start spawning
	spawn_manager.start(current_level, player)

	_set_overlay(false)
	_clear_enemies()
	_update_wave_phase_label()

func _complete_level() -> void:
	state = State.LEVEL_COMPLETE
	spawn_manager.stop()
	_clear_enemies()
	var next_index = current_level_index + 1
	if next_index < all_levels.size():
		_set_overlay(true,
			"LEVEL COMPLETE!\n" + current_level.display_name + "\n\nReady for " + all_levels[next_index].display_name + "?",
			"Next Level")
	else:
		_set_overlay(true, "YOU WIN!\nAll levels cleared!", "Play Again")

func _game_over() -> void:
	state = State.GAME_OVER
	spawn_manager.stop()
	_set_overlay(true, "GAME OVER\n\nBetter luck next time!", "Try Again")

func _on_overlay_btn_pressed() -> void:
	match state:
		State.MENU:
			_start_level(0)
		State.LEVEL_COMPLETE:
			var next = current_level_index + 1
			if next < all_levels.size():
				_start_level(next)
			else:
				current_level_index = 0
				player.player_level = 1
				player.xp = 0
				player.xp_to_next = 10
				player.max_health = 100.0
				_show_menu()
		State.GAME_OVER:
			# Restart current level
			player.player_level = 1
			player.xp = 0
			player.xp_to_next = 10
			player.max_health = 100.0
			player.health = player.max_health
			_start_level(current_level_index)

# ---- UPDATE ----

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	level_elapsed += delta

	# Timer UI
	var remaining = current_level.duration_sec - level_elapsed
	var mins = int(remaining) / 60
	var secs = int(remaining) % 60
	var total_mins = int(current_level.duration_sec) / 60
	var total_secs = int(current_level.duration_sec) % 60
	lbl_time.text = "%d:%02d / %d:%02d" % [mins, secs, total_mins, total_secs]

	# Level complete when timer runs out
	if level_elapsed >= current_level.duration_sec:
		_complete_level()
		return

	# Update wave phase label
	_update_wave_phase_label()

	# Enemy-player collision damage
	_damage_timer -= delta
	if _damage_timer <= 0.0:
		_damage_timer = DAMAGE_TICK_INTERVAL
		_check_enemy_contact_damage()

func _check_enemy_contact_damage() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.global_position.distance_to(player.global_position) < 24.0:
			player.take_damage(e.get_damage())

# ---- UI HELPERS ----

func _on_player_health_changed(current: float, max_val: float) -> void:
	var pct = current / max_val
	bar_health.size.x = 200.0 * pct
	lbl_health.text = "HP: %d/%d" % [int(current), int(max_val)]

func _on_player_xp_changed(current: int, to_next: int) -> void:
	var pct = float(current) / float(to_next)
	bar_xp.size.x = 200.0 * pct
	lbl_xp.text = "XP: %d / %d" % [current, to_next]

func _on_player_level_changed(new_level: int) -> void:
	lbl_level.text = "Lv.%d" % new_level
	# Level-up flash
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 0, 0.4)
	flash.size = get_viewport().get_visible_rect().size
	ui_layer.add_child(flash)
	var tween = get_tree().create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)
	tween.tween_callback(flash.queue_free)

func _on_player_died() -> void:
	_game_over()

func _update_wave_phase_label() -> void:
	if current_level == null:
		return
	var phase_text = ""
	for wave in current_level.spawn_waves:
		if level_elapsed >= wave.start_at_sec:
			var ends = wave.end_at_sec
			if ends < 0.0 or level_elapsed < ends:
				phase_text = "Spawning: " + ", ".join(wave.enemy_ids) + " x%d" % wave.count
	lbl_wave_phase.text = phase_text

func _set_overlay(visible_state: bool, text: String = "", btn_text: String = "") -> void:
	var overlay_bg = ui_layer.get_node("OverlayBG")
	overlay_bg.visible = visible_state
	lbl_overlay.visible = visible_state
	btn_overlay.visible = visible_state
	if visible_state:
		lbl_overlay.text = text
		btn_overlay.text = btn_text

func _clear_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()

# ---- BACKGROUND TILES ----

func _rebuild_bg_tiles(level: LevelData) -> void:
	for child in bg_tile_container.get_children():
		child.queue_free()
	var vp = get_viewport().get_visible_rect()
	var tile_size = 64
	var cols = int(vp.size.x / tile_size) + 1
	var rows = int(vp.size.y / tile_size) + 1
	for row in rows:
		for col in cols:
			if (row + col) % 2 == 0:
				var tile = ColorRect.new()
				tile.color = level.bg_accent_color
				tile.size = Vector2(tile_size, tile_size)
				tile.position = Vector2(col * tile_size, row * tile_size)
				bg_tile_container.add_child(tile)
