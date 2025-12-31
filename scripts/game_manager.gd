extends Node

signal gun_picked()

func _ready():
	gun_picked.connect(_on_gun_picked)
	
func _on_gun_picked():
	var player = get_tree().current_scene.get_node("Player")
	player.pickup_gun()
