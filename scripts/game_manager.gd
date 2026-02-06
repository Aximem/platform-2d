extends Node

# Signals
signal gun_picked()
signal switch_activated(id: int)
signal reset_switch_activated(switch_id: int)
signal enemy_killed(id: int)
signal remove_gun()
signal dialogue_started(pnjId: int)
signal display_player_answer()
signal send_answer(text: String, pnjId: int)
signal validate_enigma(pnjId: int)
signal bomb_disappear(switch_id: int)
signal game_ended()
signal keyboard_close()

# Checkpoint state
var active_checkpoint_id: int = -1
var active_checkpoint_position: Vector2

func _ready():
	gun_picked.connect(_on_gun_picked)
	switch_activated.connect(_on_switch_activated)
	enemy_killed.connect(_on_enemy_killed)
	bomb_disappear.connect(_on_bomb_disappear)

	_force_landscape_on_mobile()

	# Defer to ensure the scene is fully loaded
	call_deferred("_disable_platform_tiles")

func _disable_platform_tiles():
	var tile_map_layer_platform_visible = get_tree().current_scene.get_node("TileMaps/TileMapLayerPlatformVisible")
	# Store the original tiles before clearing them
	var used_cells = tile_map_layer_platform_visible.get_used_cells()
	for cell in used_cells:
		tile_map_layer_platform_visible.erase_cell(cell)
	tile_map_layer_platform_visible.visible = false

func _force_landscape_on_mobile():
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("""
			(function() {
				function isMobile() {
					return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
				}

				if (!isMobile()) return;

				function setup() {
					if (document.getElementById('rotate-overlay')) return;

					var rotateOverlay = document.createElement('div');
					rotateOverlay.id = 'rotate-overlay';
					rotateOverlay.innerHTML = '<div style="text-align:center;"><div style="font-size:60px;">📱↔️</div><div>Tourne ton téléphone<br/>(mode paysage)</div></div>';
					rotateOverlay.style.cssText = 'display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:black;color:white;font-size:24px;z-index:99999;justify-content:center;align-items:center;font-family:sans-serif;';
					document.body.appendChild(rotateOverlay);

					function checkOrientation() {
						var isPortrait = window.innerHeight > window.innerWidth;
						rotateOverlay.style.display = isPortrait ? 'flex' : 'none';
					}

					checkOrientation();
					window.addEventListener('resize', checkOrientation);
					window.addEventListener('orientationchange', checkOrientation);
				}

				if (document.readyState === 'complete') {
					setup();
				} else {
					window.addEventListener('load', setup);
				}
			})();
		""")

# Gun logic
func _on_gun_picked():
	var player = get_tree().current_scene.get_node("Player")
	player.pickup_gun()

# Checkpoint logic
func set_active_checkpoint_id(id: int, position: Vector2):
	active_checkpoint_id = id
	active_checkpoint_position = position

func get_active_checkpoint_id() -> int:
	return active_checkpoint_id

func get_active_checkpoint_position() -> Vector2:
	return active_checkpoint_position

# Switch logic
func _on_switch_activated(id: int):
	if id == 0:
		move_water_down()

func move_water_down():
	var tile_map = get_tree().current_scene.get_node("TileMaps/TileMapLayerMovingWater")
	var camera = get_tree().current_scene.get_node("Player/Camera2D")
	var player = get_tree().current_scene.get_node("Player")
	var water_audio = get_tree().current_scene.get_node("Audio/WaterAudio")
	var tween = create_tween()
	var initial_camera_y = camera.position.y

	water_audio.play()
	
	# Disable the inputs
	player.can_move = false

	# Move camera down
	tween.tween_property(
		camera,
		"position:y",
		initial_camera_y + 500,
		0.6
	)

	# Move water down
	tween.tween_property(
		tile_map,
		"position:y",
		tile_map.position.y + 30,
		0.6
	)

	# Move camera up
	tween.tween_property(
		camera,
		"position:y",
		initial_camera_y,
		0.6
	)

	await tween.finished

	# Enable the inputs
	player.can_move = true

func _on_enemy_killed(id: int):
	if id == 0:
		var tile_map_layer_platform_visible = get_tree().current_scene.get_node("TileMaps/TileMapLayerPlatformVisible")
		# Restore the tiles from the scene data
		# Coordinates from main.tscn: AAB0ABsAAAAIAA8AAAB1ABsAAAAIAA8AAABzABsAAAAIAA8AAAA=
		tile_map_layer_platform_visible.set_cell(Vector2i(116, 27), 0, Vector2i(8, 15))
		tile_map_layer_platform_visible.set_cell(Vector2i(117, 27), 0, Vector2i(8, 15))
		tile_map_layer_platform_visible.set_cell(Vector2i(115, 27), 0, Vector2i(8, 15))
		tile_map_layer_platform_visible.visible = true

func _on_bomb_disappear(switch_id: int):
	emit_signal("reset_switch_activated", switch_id)
