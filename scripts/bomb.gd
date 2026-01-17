extends CharacterBody2D

@export var switch_id: int = 0

const GRAVITY = 980.0

func _physics_process(delta: float):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ennemy"):
		body.queue_free()
		queue_free()
		GameManager.emit_signal("bomb_disappear", switch_id)
	if body.is_in_group("moving_platform"):
		queue_free()
		GameManager.emit_signal("bomb_disappear", switch_id)
		
