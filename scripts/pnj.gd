extends CharacterBody2D

@onready var detection_area: Area2D = $DetectionArea
@onready var control: Control = $Control
@onready var label: Label = $Control/Panel/MarginContainer/Label
@onready var keyboard_enter: Sprite2D = $Control/Panel/MarginContainer/KeyboardEnter

@export var detection_range: float = 600.0
@export var id: int = -1
@export var char_delay: float = 0.03  # Delay between characters

var display_enigma: bool = false
var current_dialogue_index: int = 0
var is_typing: bool = false
var full_text: String = ""
var current_char_index: int = 0

func _ready():
	var collision_shape = detection_area.get_node("CollisionShape2D")
	var shape = RectangleShape2D.new()
	shape.size = Vector2(detection_range * 2, 50)
	collision_shape.shape = shape
	keyboard_enter.visible = false

func _process(_delta: float) -> void:
	if is_typing:
		keyboard_enter.visible = false
	else:
		keyboard_enter.visible = true
	
func _input(event: InputEvent) -> void:
	if not display_enigma:
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# If press enter during typing, display all text
			label.text = full_text
			is_typing = false
		else:
			# Next text
			current_dialogue_index += 1
			if current_dialogue_index < GameData.PNJ_DIALOGUES[id].size():
				start_typing(getDialogueByIndex(current_dialogue_index))
			else:
				# Plus de dialogues, fermer la bulle
				control.visible = false
				current_dialogue_index = 0

func start_typing(text: String) -> void:
	full_text = text
	label.text = ""
	current_char_index = 0
	is_typing = true
	type_next_char()

func type_next_char() -> void:
	if current_char_index < full_text.length():
		label.text += full_text[current_char_index]
		current_char_index += 1
		get_tree().create_timer(char_delay).timeout.connect(type_next_char)
	else:
		is_typing = false

func getDialogueByIndex(index: int) -> String:
	return GameData.PNJ_DIALOGUES[id][index]

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		display_enigma = true
		control.visible = true
		current_dialogue_index = 0
		start_typing(getDialogueByIndex(0))

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		display_enigma = false
		control.visible = false
		is_typing = false
		current_dialogue_index = 0
