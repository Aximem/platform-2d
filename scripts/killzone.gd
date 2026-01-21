extends Area2D

@onready var timer: Timer = $Timer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	GameManager.validate_enigma.connect(_on_validate_enigma)
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Check if parent (enemy) is being deleted
		if get_parent() and get_parent().is_queued_for_deletion():
			return

		GameManager.remove_gun.emit()
		
		audio_stream_player_2d.play()
		
		var player = get_tree().current_scene.get_node_or_null("Player")
		if player:
			var playerCollisionShape2D = player.get_node_or_null("CollisionShape2D")
			if playerCollisionShape2D:
				playerCollisionShape2D.set_deferred("disabled", true)
		Engine.time_scale = 0.5

		# Release inputs
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_release("climb")
		Input.action_release("descend")
		Input.action_release("jump")

		timer.start()
		
	if body.is_in_group("bombs"):
		GameManager.emit_signal("bomb_disappear", body.switch_id)

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
func _on_validate_enigma(pnjId):
	if pnjId == 1:
		queue_free()
