extends Node

# Signals
signal gun_picked()
signal switch_activated(id: int)
signal enemy_killed(id: int)

# Checkpoint state
var active_checkpoint_id: int = -1
var active_checkpoint_position: Vector2

func _ready():
	gun_picked.connect(_on_gun_picked)
	switch_activated.connect(_on_switch_activated)
	enemy_killed.connect(_on_enemy_killed)

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
	var tween = create_tween()
	var initial_camera_y = camera.position.y

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
		var falling_platform = get_tree().current_scene.get_node("FallingPlatforms/FallingPlatform5")
		falling_platform.visible = true
