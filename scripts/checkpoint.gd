extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var checkpoint_id: int = 0

func _on_body_entered(_body: Node2D) -> void:
	sprite_2d.texture = load("res://assets/flag_green_b.png")
	
	# Test to prevent case user goes back and active an old checkpoint
	var current_checkpoint_id = CheckpointManager.get_active_checkpoint_id()
	if checkpoint_id > current_checkpoint_id:
		CheckpointManager.set_active_checkpoint_id(checkpoint_id, self.global_position)
		
	
