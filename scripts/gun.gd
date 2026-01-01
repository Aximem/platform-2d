extends Area2D

var gun_picked: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not gun_picked:
		GameManager.gun_picked.emit()
		visible = false
		gun_picked = true
