extends CharacterBody2D

const SPEED = 130
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 150.0
const SLIDE_SPEED = 300.0
const SLIDE_GRAVITY_MULTIPLIER = 1.5  # Augmented gravity on slide
const SLIDE_ACCELERATION = 1000.0

var is_climbing: bool = false
var can_climb: bool = false

var is_sliding: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

func _physics_process(delta: float) -> void:
	check_if_on_climbable()
	check_if_on_slidable()
	
	if is_climbing:
		handle_climbing(delta)
	elif is_sliding:
		handle_sliding(delta)
	else:
		handle_normal_movement(delta)
		
	move_and_slide()

func handle_climbing(_delta: float):
	animated_sprite.play("climb")
	
	# Disable gravity
	velocity.y = 0
	velocity.x = 0
	
	if Input.is_action_pressed("climb"):
		# Climb
		velocity.y = -CLIMB_SPEED
	elif Input.is_action_pressed("descend"):
		# Descend
		velocity.y = CLIMB_SPEED
		
func handle_sliding(delta: float):
	animated_sprite.play("slide")
	
	# Accélération progressive vers la vitesse de glissade
	var target_velocity_x = SLIDE_SPEED
	velocity += get_gravity() * delta  # ✅ Applique la gravité
	velocity.x = move_toward(velocity.x, target_velocity_x, SLIDE_ACCELERATION * delta)
	
	# Permet de sauter
	if Input.is_action_just_pressed("jump"):
		is_sliding = false
		velocity.y = JUMP_VELOCITY
	
func handle_normal_movement(delta: float):
	if (can_climb and Input.is_action_pressed("climb")) or (can_climb and Input.is_action_pressed("descend") or is_climbing) :
		is_climbing = true
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	#Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func check_if_on_climbable():
	var player_pos_in_tile_map = tile_map_layer.to_local(global_position)
	var tile_pos = tile_map_layer.local_to_map(Vector2(player_pos_in_tile_map.x, player_pos_in_tile_map.y - 16))
	var tile_data = tile_map_layer.get_cell_tile_data(tile_pos)
	if tile_data:
		can_climb = tile_data.get_custom_data("is_climbable")
	else:
		can_climb = false
		
	# Reach top of climb
	if not can_climb and is_climbing:
		is_climbing = false

func check_if_on_slidable():
	# Vérifie plusieurs points sous le joueur pour une détection fiable
	var player_local_pos = tile_map_layer.to_local(global_position)
	
	# Points à vérifier : centre, gauche, droite sous les pieds
	var check_points = [
		Vector2(player_local_pos.x, player_local_pos.y + 24),      # Centre bas
		Vector2(player_local_pos.x - 24, player_local_pos.y + 24),  # Gauche bas
		Vector2(player_local_pos.x + 24, player_local_pos.y + 24),  # Droite bas
	]
	
	var found_slidable = false

	# Vérifie chaque point
	for point in check_points:
		var tile_pos = tile_map_layer.local_to_map(point)
		var tile_data = tile_map_layer.get_cell_tile_data(tile_pos)
		
		if tile_data and tile_data.get_custom_data("is_slidable"):
			found_slidable = true

	if found_slidable and is_on_floor():
		is_sliding = true
	else:
		is_sliding = false
