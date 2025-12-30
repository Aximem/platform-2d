extends Node

var active_checkpoint_id: int = 0
var active_checkpoint_position: Vector2

func set_active_checkpoint_id(id: int, position: Vector2): 
	active_checkpoint_id = id
	active_checkpoint_position = position

func get_active_checkpoint_id() -> int:
	return active_checkpoint_id
	
func get_active_checkpoint_position() -> Vector2:
	return active_checkpoint_position
