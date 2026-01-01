extends Area2D

const BULLET_SPEED = 300
const MAX_DISTANCE = 100

var direction: float = 1.0
var distance_traveled: float = 0.0

func _physics_process(delta: float):
	var movement = BULLET_SPEED * delta * direction
	position.x += movement
	distance_traveled += abs(movement)

	print(distance_traveled)
	if distance_traveled >= MAX_DISTANCE:
		queue_free()
