# Enemy.gd
extends CharacterBody2D

@export var chase_speed: float = 50.0
@export var detection_range: float = 600.0
@export var id: int = -1

@onready var detection_area: Area2D = $DetectionArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var collision_shape_2d: CollisionShape2D = $BodyArea/CollisionShape2D
@onready var impact_area: Marker2D = $ImpactArea

var projectile_impact = preload("res://scenes/projectile_impact.tscn")

var player: CharacterBody2D = null
var is_chasing: bool = false
var health_point: int = GameData.ENNEMY_HEALTH_POINT
var progress_gradient: Gradient

const GRAVITY = 980.0

func _ready():
	var collision_shape = detection_area.get_node("CollisionShape2D")
	var shape = RectangleShape2D.new()
	shape.size = Vector2(detection_range * 2, 50)
	collision_shape.shape = shape

	# Get sizes from elements
	var body_width = (collision_shape_2d.shape as RectangleShape2D).size.x
	var bar_height = int(health_bar.size.y)

	# Grey background
	var under_texture = GradientTexture2D.new()
	under_texture.width = int(body_width)
	under_texture.height = bar_height
	under_texture.gradient = Gradient.new()
	under_texture.gradient.set_color(0, Color(0.2, 0.2, 0.2))
	under_texture.gradient.set_color(1, Color(0.2, 0.2, 0.2))
	health_bar.texture_under = under_texture

	# Green
	var progress_texture = GradientTexture2D.new()
	progress_texture.width = int(body_width)
	progress_texture.height = bar_height
	progress_gradient = Gradient.new()
	progress_gradient.set_color(0, Color.GREEN)
	progress_gradient.set_color(1, Color.GREEN)
	progress_texture.gradient = progress_gradient
	health_bar.texture_progress = progress_texture

	health_bar.max_value = GameData.ENNEMY_HEALTH_POINT
	health_bar.value = health_point

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

func _on_body_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		area.queue_free()
		impact()
		# Apply damage
		health_point -= GameData.BULLET_DAMAGE
		update_health_bar()
		if health_point <= 0:
			queue_free()
			GameManager.enemy_killed.emit(id)
			
func impact():
	randomize()
	var x_pos = randi() % 31
	randomize()
	var y_pos = randi() % 31
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.scale = Vector2(2, 2)
	new_impact.position = impact_location
	impact_area.add_child(new_impact)
	
func update_health_bar():
	var tween = create_tween()
	tween.tween_property(health_bar, "value", health_point, 0.2)

	# Calculate health bar color based on health points
	var ratio = float(health_point) / GameData.ENNEMY_HEALTH_POINT
	var new_color: Color
	if ratio > 0.5:
		# Green to Orange
		var t = (ratio - 0.5) / 0.5
		new_color = Color.ORANGE.lerp(Color.GREEN, t)
	else:
		# Orange to Red
		var t = ratio / 0.5
		new_color = Color.RED.lerp(Color.ORANGE, t)

	tween.parallel().tween_method(set_health_bar_color, progress_gradient.get_color(0), new_color, 0.2)

func set_health_bar_color(color: Color):
	progress_gradient.set_color(0, color)
	progress_gradient.set_color(1, color)
