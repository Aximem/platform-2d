extends AudioStreamPlayer

@onready var music: AudioStreamPlayer = $"."

var win_sound: AudioStream = preload("res://assets/audio/win/win.mp3")

func _ready() -> void:
	GameManager.game_ended.connect(_on_game_ended)
	
func _on_game_ended():
	music.stream = win_sound
	music.play()
	await get_tree().create_timer(10.0).timeout
	music.stop()
