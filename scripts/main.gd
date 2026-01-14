extends Node2D

@onready var tile_map_layer_bridge: TileMapLayer = $TileMaps/TileMapLayerBridge
@onready var moving_platform: AnimatableBody2D = $TileMaps/MovingPlatform

var platform_speed: float = 75.0
var platform_direction: int = 1  # 1 = droite, -1 = gauche
var platform_initial_position: Vector2
var platform_max_distance: float = 125.0

func _ready() -> void:
	GameManager.validate_enigma.connect(_on_validate_enigma)

	tile_map_layer_bridge.visible = false
	tile_map_layer_bridge.collision_enabled = false

	platform_initial_position = moving_platform.position

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
