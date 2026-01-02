extends Area2D

const BULLET_SPEED = 300
const MAX_DISTANCE = 90

var direction: float = 1.0
var distance_traveled: float = 0.0

func _ready():
	add_to_group("bullets")

func _physics_process(delta: float):
	var movement = BULLET_SPEED * delta * direction
	position.x += movement
	distance_traveled += abs(movement)

	if distance_traveled >= MAX_DISTANCE:
		queue_free()
