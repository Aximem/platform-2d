extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.remove_gun.emit()
		print("Dead")
		var playerCollisionShape2D: CollisionShape2D = get_tree().current_scene.get_node("Player/CollisionShape2D")
		playerCollisionShape2D.set_deferred("disabled", true)
		Engine.time_scale = 0.5
		
		# Release inputs
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_release("climb")
		Input.action_release("descend")
		Input.action_release("jump")
		
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
