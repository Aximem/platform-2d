extends StaticBody2D

@onready var block: Sprite2D = $Block
@onready var timer: Timer = $Timer

var initial_position: Vector2
var is_falling: bool = false
var fall_velocity: Vector2 = Vector2.ZERO
const RESPAWN_TIME: float = 1.0

func _ready():
	initial_position = global_position
	
func _process(delta: float):
	if is_falling:
		var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		fall_velocity.y += gravity * delta
		global_position += fall_velocity * delta
		
		# Hide and redisplay block 
		if global_position.y > initial_position.y + 200:
			respawn_block()

func respawn_block():
	# Hide block
	visible = false
	is_falling = false
	fall_velocity = Vector2.ZERO
	
	# Redisplay block with 
	global_position = initial_position
	block.texture = load("res://assets/falling_block/block_rest.png")
	
	# Redisplay the block
	visible = true
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		block.texture = load("res://assets/falling_block/block_idle.png")
		timer.start()
		
func _on_timer_timeout() -> void:
	block.texture = load("res://assets/falling_block/block_fall.png")
	is_falling = true
	fall_velocity = Vector2.ZERO
	timer.stop()
