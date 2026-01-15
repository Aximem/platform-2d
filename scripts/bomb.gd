extends CharacterBody2D

@export var switch_id: int = 0

const GRAVITY = 980.0

func _physics_process(delta: float):
# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	move_and_slide()
