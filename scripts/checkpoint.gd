extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var checkpoint_id: int = 0
var activated: bool = false

func _ready():
	if GameManager.active_checkpoint_id == checkpoint_id:
		activated = true
		sprite_2d.texture = load("res://assets/checkpoint/flag_green_b.png")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not activated and not GameManager.active_checkpoint_id == checkpoint_id:
		sprite_2d.texture = load("res://assets/checkpoint/flag_green_b.png")
		cpu_particles_2d.emitting = true
		activated = true
		audio_stream_player_2d.play(0.3)
		# Test to prevent case user goes back and active an old checkpoint
		var current_checkpoint_id = GameManager.get_active_checkpoint_id()
		if checkpoint_id > current_checkpoint_id:
			GameManager.set_active_checkpoint_id(checkpoint_id, self.global_position)
		
	
