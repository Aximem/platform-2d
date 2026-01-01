# Enemy.gd
extends CharacterBody2D

@export var chase_speed: float = 50.0
@export var detection_range: float = 600.0

@onready var detection_area: Area2D = $DetectionArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D = null
var is_chasing: bool = false

const GRAVITY = 980.0

func _ready():
	var collision_shape = detection_area.get_node("CollisionShape2D")
	var shape = RectangleShape2D.new()
	shape.size = Vector2(detection_range * 2, 50)
	collision_shape.shape = shape

func _physics_process(_delta: float):
	if is_chasing and player:
		chase_player()
	
	move_and_slide()

func chase_player():
	# Get player direction
	var direction = sign(player.global_position.x - global_position.x)
	
	# Move ennemy to the player
	velocity.x = direction * chase_speed
	
	if direction > 0:
		animated_sprite_2d.scale.x = 1 
	elif direction < 0:
		animated_sprite_2d.scale.x = -1

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		is_chasing = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		is_chasing = false
		velocity.x = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Kill player
		pass
		
