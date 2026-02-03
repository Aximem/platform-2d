extends Node2D

@onready var tile_map_layer_bridge: TileMapLayer = $TileMaps/TileMapLayerBridge
@onready var moving_platform: AnimatableBody2D = $TileMaps/MovingPlatform
@onready var boom_label: Label = $Bombs/BoomLabel
@onready var explosion_audio: AudioStreamPlayer2D = $Audio/ExplosionAudio

var platform_speed: float = 65.0
var platform_direction: int = 1  # 1 = droite, -1 = gauche
var platform_initial_position: Vector2
var platform_max_distance: float = 95.0

var bomb_scene: PackedScene = preload("res://scenes/bomb.tscn")
var bomb_spawn_position: Vector2 = Vector2(2875.0, 250.0)

func _ready() -> void:
	GameManager.validate_enigma.connect(_on_validate_enigma)
	GameManager.switch_activated.connect(_on_switch_activated)
	GameManager.bomb_disappear.connect(_on_bomb_disappear)

	tile_map_layer_bridge.visible = false
	tile_map_layer_bridge.collision_enabled = false

	platform_initial_position = moving_platform.position
	
	boom_label.visible = false

func _physics_process(delta: float) -> void:
	_move_platform(delta)

func _move_platform(delta: float) -> void:
	# Move the platform
	moving_platform.global_position.x += platform_speed * platform_direction * delta

	var current_offset = moving_platform.global_position.x - platform_initial_position.x

	# Atteint la limite droite
	if current_offset >= platform_max_distance:
		moving_platform.global_position.x = platform_initial_position.x + platform_max_distance
		platform_direction = -1
	# Revenu à la position initiale
	elif current_offset <= 0:
		moving_platform.global_position.x = platform_initial_position.x
		platform_direction = 1

func _on_validate_enigma(_pnjId: int):
	tile_map_layer_bridge.visible = true
	tile_map_layer_bridge.collision_enabled = true
	
func _on_switch_activated(id: int):
	if id == 1:
		var bomb = bomb_scene.instantiate()
		bomb.switch_id = 1
		bomb.z_index = 1
		bomb.scale.x = 0.25
		bomb.scale.y = 0.25
		bomb.global_position = bomb_spawn_position
		add_child(bomb)
		boom_label.visible = true
		
func _on_bomb_disappear(_switch_id: int):
	explosion_audio.play()
