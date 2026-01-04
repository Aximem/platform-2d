extends CanvasLayer

const BUTTON_SIZE_PERCENT = 0.10  # 10% de la hauteur de l'écran
const MARGIN_PERCENT = 0.03  # 3% de la hauteur pour les marges
const SPACING_PERCENT = 0.02  # 2% de la hauteur pour l'espacement

@onready var margin_container: MarginContainer = $Control/MarginContainer
@onready var hbox_container: HBoxContainer = $Control/MarginContainer/Control/HBoxContainer
@onready var vbox_container: VBoxContainer = $Control/MarginContainer/Control/HBoxContainer/Control2/VBoxContainer

@onready var control_left: Control = $Control/MarginContainer/Control/HBoxContainer/Control
@onready var control_center: Control = $Control/MarginContainer/Control/HBoxContainer/Control2
@onready var control_right: Control = $Control/MarginContainer/Control/HBoxContainer/Control3
@onready var control_jump: Control = $Control/MarginContainer/Control/Control2

@onready var left_touch: TouchScreenButton = $Control/MarginContainer/Control/HBoxContainer/Control/LeftTouch
@onready var right_touch: TouchScreenButton = $Control/MarginContainer/Control/HBoxContainer/Control3/RightTouch
@onready var top_touch: TouchScreenButton = $Control/MarginContainer/Control/HBoxContainer/Control2/VBoxContainer/TopTouch
@onready var bottom_touch: TouchScreenButton = $Control/MarginContainer/Control/HBoxContainer/Control2/VBoxContainer/BottomTouch
@onready var jump_touch: TouchScreenButton = $Control/MarginContainer/Control/Control2/JumpTouch

func _ready() -> void:
	resize_all()
	get_tree().root.size_changed.connect(resize_all)

func resize_all() -> void:
	var screen_height = get_viewport().get_visible_rect().size.y
	var button_size = int(screen_height * BUTTON_SIZE_PERCENT)
	var margin_size = int(screen_height * MARGIN_PERCENT)
	var spacing_size = int(screen_height * SPACING_PERCENT)

	# Marges
	margin_container.add_theme_constant_override("margin_left", margin_size)
	margin_container.add_theme_constant_override("margin_right", margin_size)
	margin_container.add_theme_constant_override("margin_top", margin_size)
	margin_container.add_theme_constant_override("margin_bottom", margin_size)

	# Espacement entre boutons
	hbox_container.add_theme_constant_override("separation", spacing_size)
	# VBox: espace d'un bouton entre top et bottom
	vbox_container.add_theme_constant_override("separation", button_size + spacing_size * 2)

	# D-pad en croix : 3 boutons de haut, 3 boutons de large
	# Layout:
	#        [TOP]
	# [LEFT]       [RIGHT]
	#       [BOTTOM]

	var jump_size = int(button_size * 1.5)
	var dpad_size = button_size * 3 + spacing_size * 2  # 3 boutons + 2 espacements

	# Tous les wrappers ont la même hauteur pour le HBox
	control_left.custom_minimum_size = Vector2(button_size, dpad_size)
	control_center.custom_minimum_size = Vector2(button_size, dpad_size)
	control_right.custom_minimum_size = Vector2(button_size, dpad_size)
	control_jump.custom_minimum_size = Vector2(jump_size, jump_size)

	# Offset du control_jump pour aligner le bas avec le bas du D-pad
	control_jump.offset_left = -jump_size
	control_jump.offset_top = -jump_size
	control_jump.offset_right = 0
	control_jump.offset_bottom = 0

	# Taille du HBoxContainer
	hbox_container.custom_minimum_size = Vector2(dpad_size, dpad_size)

	# Redimensionner les boutons
	var buttons = [left_touch, right_touch, top_touch, bottom_touch, jump_touch]
	for button in buttons:
		if button and button.texture_normal:
			var texture_size = button.texture_normal.get_size()
			var scale_factor = float(button_size) / texture_size.y
			button.scale = Vector2(scale_factor, scale_factor)

	# Jump est plus gros
	if jump_touch and jump_touch.texture_normal:
		var texture_size = jump_touch.texture_normal.get_size()
		var scale_factor = float(button_size * 1.5) / texture_size.y
		jump_touch.scale = Vector2(scale_factor, scale_factor)

	# Repositionner les boutons en croix (D-pad style manette)
	# Left et Right au milieu verticalement (alignés entre top et bottom)
	left_touch.position = Vector2(0, button_size + spacing_size)
	right_touch.position = Vector2(0, button_size + spacing_size)
	# Top en haut, Bottom en bas
	top_touch.position = Vector2(0, spacing_size)
	bottom_touch.position = Vector2(0, button_size * 2 + spacing_size)
	# Jump
	jump_touch.position = Vector2.ZERO

func _on_left_touch_pressed() -> void:
	Input.action_press("move_left")

func _on_left_touch_released() -> void:
	Input.action_release("move_left")

func _on_right_touch_pressed() -> void:
	Input.action_press("move_right")

func _on_right_touch_released() -> void:
	Input.action_release("move_right")

func _on_top_touch_pressed() -> void:
	Input.action_press("climb")

func _on_top_touch_released() -> void:
	Input.action_release("climb")

func _on_bottom_touch_pressed() -> void:
	Input.action_press("descend")

func _on_bottom_touch_released() -> void:
	Input.action_release("descend")

func _on_jump_touch_pressed() -> void:
	Input.action_press("jump")

func _on_jump_touch_released() -> void:
	Input.action_release("jump")
