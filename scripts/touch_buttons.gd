extends CanvasLayer

const BUTTON_SIZE_PERCENT = 0.20 # 20% de la hauteur de l'écran
const MARGIN_PERCENT = 0.06 # 3% de la hauteur pour les marges
const SPACING_PERCENT = 0.02 # 2% de la hauteur pour l'espacement

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
@onready var touch_screen_button: TouchScreenButton = $Control/Panel/MarginContainer/TouchScreenButton
@onready var onscreen_keyboard: PanelContainer = $Control/OnscreenKeyboard

# Audio unlock for mobile browsers
var audio_unlocked: bool = false
var start_button: Button = null

func _ready() -> void:
	if not _is_mobile_device():
		visible = false
		onscreen_keyboard.set_process_input(false)
		return

	onscreen_keyboard.visibility_changed.connect(_on_keyboard_visibility_changed)
	GameManager.display_player_answer.connect(_on_display_player_answer)
	GameManager.send_answer.connect(_on_send_answer)
	GameManager.game_ended.connect(_on_game_ended)

	# Disable auto_show to prevent keyboard from hiding automatically
	onscreen_keyboard.auto_show = false

	# Disable animation to prevent position issues
	onscreen_keyboard.animate = false

	# Create start button for mobile audio unlock
	_create_start_button()

	resize_all()
	get_tree().root.size_changed.connect(resize_all)

func _create_start_button() -> void:
	if not _is_mobile_device() or OS.get_name() != "Web":
		return

	# Create a fullscreen button overlay
	start_button = Button.new()
	start_button.text = "TAP TO START"
	start_button.add_theme_font_size_override("font_size", 40)

	# Style the button
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.8)
	style_box.border_color = Color(1, 1, 1, 1)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	start_button.add_theme_stylebox_override("normal", style_box)
	start_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))

	# Make it fullscreen
	start_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	start_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	start_button.grow_vertical = Control.GROW_DIRECTION_BOTH

	# Add to scene
	$Control.add_child(start_button)
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	_unlock_audio()
	if start_button:
		start_button.queue_free()
		start_button = null

func _unlock_audio() -> void:
	if not audio_unlocked and _is_mobile_device():
		# On mobile browsers, we need to play a sound after user interaction to unlock audio
		# Create a temporary AudioStreamPlayer with a very short silent sound
		if OS.get_name() == "Web":
			# Use JavaScript to unlock the AudioContext
			JavaScriptBridge.eval("""
				if (typeof AudioContext !== 'undefined' || typeof webkitAudioContext !== 'undefined') {
					var AudioContext = window.AudioContext || window.webkitAudioContext;
					var context = new AudioContext();
					if (context.state === 'suspended') {
						context.resume();
					}
					// Play a silent buffer to unlock
					var buffer = context.createBuffer(1, 1, 22050);
					var source = context.createBufferSource();
					source.buffer = buffer;
					source.connect(context.destination);
					source.start(0);
				}
			""")
		audio_unlocked = true
		print("Audio unlocked on mobile browser")

func _on_keyboard_visibility_changed():
	if not _is_mobile_device():
		pass
	if not onscreen_keyboard.visible:
		GameManager.keyboard_close.emit()
	
func _on_display_player_answer():
	onscreen_keyboard.show()

func _on_send_answer(_text: String, _pnjId: int):
	onscreen_keyboard.hide()
	
func _is_mobile_device() -> bool:
	var os_name = OS.get_name()

	# Native mobile
	if os_name in ["Android", "iOS"]:
		return true

	# Web: detect mobile browser via JavaScript
	if os_name == "Web":
		var is_mobile = JavaScriptBridge.eval("""
			/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
			|| (navigator.maxTouchPoints > 0 && /Mobi|Android/i.test(navigator.userAgent))
		""")
		return is_mobile

	return false

func resize_all() -> void:
	var screen_height = get_viewport().get_visible_rect().size.y
	var button_size = int(screen_height * BUTTON_SIZE_PERCENT)
	var margin_size = int(screen_height * MARGIN_PERCENT)
	var spacing_size = int(screen_height * SPACING_PERCENT)

	# Marges
	margin_container.add_theme_constant_override("margin_left", margin_size)
	margin_container.add_theme_constant_override("margin_right", margin_size)
	margin_container.add_theme_constant_override("margin_top", margin_size)
	margin_container.add_theme_constant_override("margin_bottom", margin_size / 2)

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
	var dpad_size = button_size * 3 + spacing_size * 2 # 3 boutons + 2 espacements

	# Tous les wrappers ont la même hauteur pour le HBox
	control_left.custom_minimum_size = Vector2(button_size, dpad_size)
	control_center.custom_minimum_size = Vector2(button_size, dpad_size)
	control_right.custom_minimum_size = Vector2(button_size, dpad_size)
	control_jump.custom_minimum_size = Vector2(jump_size, jump_size)

	# Centrer le bouton Jump verticalement par rapport au D-pad
	# Le centre du D-pad est à dpad_size / 2 depuis le bas
	# On positionne le centre du Jump au même niveau
	var dpad_center_from_bottom = dpad_size / 2.0
	var jump_offset_top = - (dpad_center_from_bottom + jump_size / 2.0)
	control_jump.offset_left = - jump_size
	control_jump.offset_top = jump_offset_top
	control_jump.offset_right = 0
	control_jump.offset_bottom = - (dpad_center_from_bottom - jump_size / 2.0)

	# Taille du HBoxContainer
	hbox_container.custom_minimum_size = Vector2(dpad_size, dpad_size)

	# Redimensionner les boutons
	var buttons = [left_touch, right_touch, top_touch, bottom_touch, jump_touch]
	for button in buttons:
		if button and button.texture_normal:
			var texture_size = button.texture_normal.get_size()
			var scale_factor = float(button_size) / texture_size.y
			button.scale = Vector2(scale_factor, scale_factor)

	# Left et Right plus larges de 20px
	if left_touch and left_touch.texture_normal:
		var extra_width = 20.0 / left_touch.texture_normal.get_size().x
		left_touch.scale.x += extra_width
	if right_touch and right_touch.texture_normal:
		var extra_width = 20.0 / right_touch.texture_normal.get_size().x
		right_touch.scale.x += extra_width

	# Jump est plus gros
	if jump_touch and jump_touch.texture_normal:
		var texture_size = jump_touch.texture_normal.get_size()
		var scale_factor = float(button_size * 1.5) / texture_size.y
		jump_touch.scale = Vector2(scale_factor, scale_factor)

	# Redimensionner le clavier virtuel (30% de la hauteur de l'écran, 60% de la largeur)
	var keyboard_height = int(screen_height * 0.4)
	var screen_width = get_viewport().get_visible_rect().size.x
	var keyboard_width = int(screen_width * 0.6)
	onscreen_keyboard.custom_minimum_size = Vector2(keyboard_width, keyboard_height)
	# Repositionner le clavier pour qu'il soit centré horizontalement et visible en bas
	onscreen_keyboard.offset_left = - keyboard_width / 2
	onscreen_keyboard.offset_right = keyboard_width / 2
	onscreen_keyboard.offset_top = - keyboard_height - margin_size # Ajouter une marge pour ne pas sortir de l'écran
	onscreen_keyboard.offset_bottom = 0
	
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

func _on_game_ended():
	visible = false
