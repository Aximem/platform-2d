extends CharacterBody2D

const SPEED = 130
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 150.0
const SLIDE_SPEED = 400.0
const SLIDE_ACCELERATION = 400.0
const SLIDE_FRICTION = 50.0
const SLIDE_OVERSHOOT_DISTANCE = 16.0
const CLIMB_HORIZONTAL_SPEED = 100.0
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const SHOOT_COOLDOWN = 0.2

# Climbing
var is_climbing: bool = false
var can_climb: bool = false

# Sliding
var is_sliding: bool = false
var was_sliding: bool = false
var slide_momentum: float = 0.0
var slide_distance_remaining: float = 0.0

# Used to disable inputs
var can_move: bool = true

# Gun
var has_gun: bool = false
var can_shoot: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tile_map_layer_tiles: TileMapLayer = $"../TileMaps/TileMapLayerTiles"
@onready var tile_map_layer_moving_water: TileMapLayer = $"../TileMaps/TileMapLayerMovingWater"
@onready var gun: Sprite2D = $AnimatedSprite2D/Gun
@onready var answer_control: Control = $AnswerControl
@onready var line_edit: LineEdit = $AnswerControl/Panel/MarginContainer/LineEdit
@onready var keyboard_enter: Sprite2D = $AnswerControl/Panel/MarginContainer/KeyboardEnter

@onready var bridges: Array[StaticBody2D] = [
	$"../Bridges/Bridge",
	$"../Bridges/Bridge2",
	$"../Bridges/Bridge3",
	$"../Bridges/Bridge4",
	$"../Bridges/Bridge5",
	$"../Bridges/Bridge6",
	$"../Bridges/Bridge7",
	$"../Bridges/Bridge8",
	$"../Bridges/Bridge9",
	$"../Bridges/Bridge10",
	$"../Bridges/Bridge11"
]

func _ready() -> void:
	gun.visible = false
	answer_control.visible = false
	keyboard_enter.visible = false
	
	disable_bridges()
	GameManager.switch_activated.connect(_on_switch_activated)
	GameManager.enemy_killed.connect(_on_enemy_killed)
	GameManager.remove_gun.connect(_on_remove_gun)
	GameManager.display_player_answer.connect(_on_display_player_answer)
	GameManager.dialogue_started.connect(_on_dialogue_started)
	GameManager.dialogue_ended.connect(_on_dialogue_ended)

	var checkpoint_id = GameManager.get_active_checkpoint_id()
	if checkpoint_id != -1:
		var checkpoint_pos = GameManager.get_active_checkpoint_position()
		global_position = checkpoint_pos
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	
	check_if_on_climbable()
	check_if_on_slidable()
	
	if has_gun:
		shoot()
	
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
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			was_sliding = false
			slide_momentum = 0
			slide_distance_remaining = 0
			velocity.y = JUMP_VELOCITY
			return
			
		# If momentum is too weak, cancel it immediately to prevent being stuck
		if abs(slide_momentum) < 50:  # Minimum velocity treshold
			was_sliding = false
			slide_momentum = 0
			slide_distance_remaining = 0
		else:
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
			
			return
	
	# Normal mode, no inertia
	was_sliding = false
	slide_momentum = 0
	slide_distance_remaining = 0
	
	if can_climb and (Input.is_action_pressed("climb") or Input.is_action_pressed("descend")):
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
		animated_sprite.scale.x = 1
	elif direction < 0:
		animated_sprite.scale.x = -1
		
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
		
func disable_bridges():
	for bridge in bridges:
		var collision = bridge.get_node("CollisionShape2D")
		collision.set_deferred("disabled", true)

func enable_bridges():
	for bridge in bridges:
		var collision = bridge.get_node("CollisionShape2D")
		collision.set_deferred("disabled", false)	
		
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

func pickup_gun(): 
	has_gun = true
	gun.visible = true

func _on_switch_activated(id: int):
	if id == 0:
		enable_bridges()

func shoot():
	if not can_shoot:
		return

	can_shoot = false

	var bullet = BULLET_SCENE.instantiate()
	bullet.direction = animated_sprite.scale.x
	bullet.global_position = gun.global_position
	bullet.scale = Vector2(0.25, 0.25)
	get_parent().add_child(bullet)

	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true

func _on_enemy_killed(_id: int):
	# Remove gun
	can_shoot = false
	has_gun = false
	gun.visible = false

func _on_remove_gun():
	can_shoot = false
	has_gun = false
	gun.visible = false

func _on_dialogue_started():
	can_move = false
	
func _on_dialogue_ended():
	can_move = true
	
func _on_display_player_answer():
	answer_control.visible = true
	line_edit.grab_focus.call_deferred()
	line_edit.caret_blink = true
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit.text = ""
	answer_control.visible = false
	GameManager.send_answer.emit(new_text)

func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text.length() > 0:
		keyboard_enter.visible = true
	else:
		keyboard_enter.visible = false
