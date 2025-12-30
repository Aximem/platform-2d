extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	print("Dead")
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	var active_checkpoint_id = CheckpointManager.get_active_checkpoint_id()
	if active_checkpoint_id == 0:
		get_tree().reload_current_scene()
	else:
		var active_checkpoint_position = CheckpointManager.get_active_checkpoint_position()
		var player = get_node("/root/Main/Player")
		player.global_position = active_checkpoint_position
		timer.stop()
