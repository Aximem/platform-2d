extends Area2D

enum SwitchColor {
	Blue,
	Green,
	Red,
	Yellow
}

@export var color: SwitchColor = SwitchColor.Blue

@onready var sprite_2d: Sprite2D = $Sprite2D

func _get_color_text() -> String:
	var color_text: String = "blue"
		
	match color:
		SwitchColor.Green:
			color_text = "green"
		SwitchColor.Red:
			color_text = "red"
		SwitchColor.Yellow:
			color_text = "yellow"
			
	return color_text
	
func _ready() -> void:
	sprite_2d.texture = load("res://assets/switch/switch_" + _get_color_text() + ".png")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		sprite_2d.texture = load("res://assets/switch/switch_" + _get_color_text() + "_pressed.png")
	
	
