extends CharacterBody2D

const SPEED = 130
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 150.0
const SLIDE_SPEED = 400.0
const SLIDE_ACCELERATION = 400.0
const SLIDE_FRICTION = 50.0
const SLIDE_OVERSHOOT_DISTANCE = 12.0
const CLIMB_HORIZONTAL_SPEED = 100.0

# Climbing
var is_climbing: bool = false
var can_climb: bool = false

# Sliding
var is_sliding: bool = false
var was_sliding: bool = false
var slide_momentum: float = 0.0
var slide_distance_remaining: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map_layer_tiles: TileMapLayer = $"../TileMapLayerTiles"

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
	
	# reset momentum
	slide_momentum = 0
	# Disable gravity
	velocity.y = 0
	velocity.x = 0
	
	if Input.is_action_pressed("climb"):
		# Climb
		velocity.y = -CLIMB_SPEED
	elif Input.is_action_pressed("descend"):
		# Descend
		velocity.y = CLIMB_SPEED
		
	# Horizontal movement (left/right)
	var horizontal_direction := Input.get_axis("move_left", "move_right")
	if horizontal_direction != 0:
		velocity.x = horizontal_direction * CLIMB_HORIZONTAL_SPEED
	
	# Jump while climbing
	if Input.is_action_just_pressed("jump"):
		is_climbing = false
		velocity.y = JUMP_VELOCITY
		# Keep horizontal speed if player is moving horizontally
		if horizontal_direction != 0:
			velocity.x = horizontal_direction * SPEED
	
	# IMPORTANT: check if we cannot climb anymore, make player stop climbing and fall
	if not can_climb:
		is_climbing = false
		# Apply gravity to fall
		velocity.y = 0
		
func handle_sliding(delta: float):
	animated_sprite.play("slide")
	
	# Activate floor snapping, 8 pixels distance on the floor
	floor_snap_length = 8.0
	
	var target_velocity_x = SLIDE_SPEED
	velocity += get_gravity() * delta 
	velocity.x = move_toward(velocity.x, target_velocity_x, SLIDE_ACCELERATION * delta)
	
	was_sliding = true
	# Save sliding velocity
	slide_momentum = velocity.x
	slide_distance_remaining = SLIDE_OVERSHOOT_DISTANCE
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_sliding = false
		was_sliding = false  
		slide_momentum = 0  
		slide_distance_remaining = 0
		floor_snap_length = 0 # Disable the snap when jumping
		velocity.y = JUMP_VELOCITY
		return
	
func handle_normal_movement(delta: float):
	floor_snap_length = 0 # Disable floor snapping on normal movement
	
	# Just finished sliding
	if was_sliding and slide_distance_remaining > 0:
		# Calculate distance traveled
		var distance_moved = abs(velocity.x * delta)
		slide_distance_remaining -= distance_moved

		# Add friction
		slide_momentum = move_toward(slide_momentum, 0, SLIDE_FRICTION * delta)
		
		# Continue with slide velocity
		velocity.x = slide_momentum
		
		# Apply gravity during slide overshoot
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		# Keep slide animation
		animated_sprite.play("slide")
			
		# When distance traveled or velocity is low, we stop player
		if slide_distance_remaining <= 0:
			was_sliding = false
			slide_momentum = 0
			slide_distance_remaining = 0
		
		return
	
	# Normal mode, no inerty
	was_sliding = false
	slide_momentum = 0
	
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
	var player_pos_in_tile_map = tile_map_layer_tiles.to_local(global_position)
	var tile_pos = tile_map_layer_tiles.local_to_map(Vector2(player_pos_in_tile_map.x, player_pos_in_tile_map.y - 16))
	var tile_data = tile_map_layer_tiles.get_cell_tile_data(tile_pos)
	if tile_data:
		can_climb = tile_data.get_custom_data("is_climbable")
	else:
		can_climb = false
		
	# Reach top of climb
	if not can_climb and is_climbing:
		is_climbing = false

func check_if_on_slidable():
	# Vérifie plusieurs points sous le joueur pour une détection fiable
	var player_local_pos = tile_map_layer_tiles.to_local(global_position)
	
	# Points à vérifier : centre, gauche, droite sous les pieds
	var check_points = [
		Vector2(player_local_pos.x, player_local_pos.y + 24),      # Centre bas
		Vector2(player_local_pos.x - 24, player_local_pos.y + 24),  # Gauche bas
		Vector2(player_local_pos.x + 24, player_local_pos.y + 24),  # Droite bas
	]
	
	var found_slidable = false

	# Vérifie chaque point
	for point in check_points:
		var tile_pos = tile_map_layer_tiles.local_to_map(point)
		var tile_data = tile_map_layer_tiles.get_cell_tile_data(tile_pos)
		
		if tile_data and tile_data.get_custom_data("is_slidable"):
			found_slidable = true

	is_sliding = found_slidable
