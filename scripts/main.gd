extends Node2D

@onready var tile_map_layer_bridge: TileMapLayer = $TileMaps/TileMapLayerBridge
@onready var tile_map_layer_moving_platform: TileMapLayer = $TileMaps/TileMapLayerMovingPlatform

func _ready() -> void:
	GameManager.validate_enigma.connect(_on_validate_enigma)
	
	tile_map_layer_bridge.visible = false
	tile_map_layer_bridge.collision_enabled = false
	
func _on_validate_enigma(pnjId: int):
	tile_map_layer_bridge.visible = true
	tile_map_layer_bridge.collision_enabled = true
