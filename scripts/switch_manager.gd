extends Node

signal switch_activated(id: int)

func _ready():
	switch_activated.connect(_on_switch_activated)
	
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
